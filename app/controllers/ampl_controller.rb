class AmplController < ApplicationController
  include ActionView::Helpers::FormTagHelper
  MODEL_FILE='public/symulacja.mod'

  def index
    if params["ampl"].present?
      newmodel = subst(model, params["ampl"])
      write_model(newmodel)
      @output = invoke_ampl(newmodel)
    end
    @inputs = ampl_form
  end

  def write_model(newmodel)
    File.open(MODEL_FILE, 'w') {|f| f.write(newmodel)}
  end

  def model
    File.read(MODEL_FILE)
  end

  def invoke_ampl(text)
    file = Tempfile.new('foo')
    file.write(text)
    file.close
    out = `/home/jg/bin/ampl/ampl < #{file.path} 2>&1`

    out
  end

  # substitute the param values in model from those in the params hash
  def subst(model, params)
    newmodel = model.dup
    params.each do |key, value|
      if value.instance_of?(Array)
        newmodel.sub!(/(#{key}\s*:=)(.+?);/m) do |match|
          $1 + value.each_with_index.map do |arg, i|
            "\r\n#{i+1} #{arg}"
          end.join("") + ';'
        end
      else
        newmodel.sub!(/(#{key}\s*:=)(.+?);/) do |match|
          "#{$1}#{value};"
        end
      end
    end

    newmodel
  end

  def log(s)
    Logger.new('stuffs').info(s)
  end

  def ampl_form
    @inputs = ""
    @inputs << "<div id='box'>"
    model_params.each do |param|
      args = param[1]
      name = param[0]
      type = param[2]
      @inputs << "<div class='control-group'>"
      if type == 'scalar'
          @inputs << input_box(param[0], param[0], args)
      else
        args.each_with_index do |arg, i|
          @inputs << input_box("#{param[0]}[#{(i+1).to_s}]: ", "#{param[0]}[]", arg)
        end
      end
      @inputs << "</div>"
    end
    @inputs << "</div>"
  end

  def ampl
  end

  def input_box(label, name, value)
    inputs = ""
    inputs << label_tag(label, nil, :class => 'control-label')
    inputs << "<div class='controls'>"
    inputs << text_field_tag("ampl[#{name}", value)
    inputs << "</div>"
  end

  # Returns array of arrays (param, array of args)
  def model_params
    lst = params_string.split(';').map{|ss| ss.split(':=')}.reject {|el| el.size != 2}

    lst.map do |param|
      name = name(param[0])
      args = args(param[1])
      type = type(param[1])
      [name, args, type]
    end
  end

  def name(str)
    str.split('param ').last
  end

  def type(str)
    if str.include?("\r\n")
      "vector"
    else
      "scalar"
    end
  end

  def args(str)
    args = str.include?("\n") ? str.split("\n").map {|el| el.split(" ").last}.compact : [str]
  end

  def params_string
    File.read('public/symulacja.mod').split('data;')[1]
  end
end
