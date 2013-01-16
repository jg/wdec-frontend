option solver '/home/jg/bin/ampl/minos';
param N;

param kosztyStale {1..2};
param zdolnoscProdukcyjna {1..N};
param amortyzacja;

param gotowka;
param kredyt;
param splacanaRata;
param jakosc {1..N};
param kosztJednostkowy{1..N};
param cenaSprzedazy {1..N};
param popyt;

param procentPopytu;
param wspolczynnikReklamy;
param celReklamy{1..3};


param eps;
param beta;
param gamma;

param a{1..4};
param r{1..4};

var wielkoscProdukcji {1..N} integer >= 0;
var promocjaInternet {1..N} integer >= 0;
var promocjaMagazyny {1..N} integer >= 0;
var promocjaTelewizja {1..N} integer >= 0;

var kosztyReklamy >= 0;
var kosztyZmienne >= 0;
var wolnaGotowka >= 0;
var docelowaProdukcja >= 0;

var zz;
var z{1..4};
var k{1..4};
var dp{1..3} >= 0;
var dm{1..3} >= 0;
var d2p >= 0;
var d2m >= 0;
var alfa;

maximize ss: zz  + eps * z[1] + eps * z[2] + eps * z[3] + eps * z[4];

subject to bankructwo: wolnaGotowka >= 0;
subject to reklamaDoProdukcji: kosztyReklamy <= wspolczynnikReklamy * kosztyZmienne;
subject to wydajnoscFabryk{i in 1..N}: wielkoscProdukcji[i] <= zdolnoscProdukcyjna[i]; 

subject to o1{i in 1..4}: z[i]<= 1 + beta * (k[i] - a[i]) / (a[i] - r[i]);
subject to o2{i in 1..4}: z[i]<= (k[i] - r[i]) / (a[i] - r[i]);
subject to o3{i in 1..4}: z[i]<= gamma * (k[i]- r[i]) / (a[i] - r[i]);
subject to o4{i in 1..4}: zz<= z[i];

subject to kosztyReklamyO: kosztyReklamy = sum{i in 1..N} promocjaInternet[i] + sum{i in 1..N} promocjaMagazyny[i] + sum{i in 1..N} promocjaTelewizja[i];
subject to kosztyZmienneO: kosztyZmienne = sum{i in 1..N} wielkoscProdukcji[i] * kosztJednostkowy[i];
subject to wolnaGotowkaO: wolnaGotowka = gotowka + kredyt - splacanaRata - amortyzacja - kosztyReklamy - kosztyStale[1] - kosztyStale[2] - kosztyZmienne;
subject to docelowaProdukcjaO: docelowaProdukcja = popyt * procentPopytu;

subject to al1{i in 1..3}: alfa >= dp[i];
subject to al2{i in 1..3}: alfa >= dm[i];

subject to odchylka1{i in 1..N}: promocjaInternet[i] - celReklamy[1] + celReklamy[1] * 0.01 * (dm[1] - dp[1]) = 0;
subject to odchylka2{i in 1..N}: promocjaMagazyny[i] - celReklamy[2] + celReklamy[2] * 0.01 * (dm[2] - dp[2]) = 0;
subject to odchylka3{i in 1..N}: promocjaTelewizja[i] - celReklamy[3] + celReklamy[3] * 0.01 * (dm[3] - dp[3]) = 0;
subject to odchtlka4: wielkoscProdukcji[1] - docelowaProdukcja + docelowaProdukcja * 0.01 * (d2m - d2p) = 0;

subject to val1: k[1] = wolnaGotowka;
subject to val2: k[2] = d2p + d2m;
subject to val3: k[3] = sum{i in 1..3} (dp[i]+dm[i]);
subject to val4: k[4] = alfa;
data;

param a:=
1 0
2 0
3 0
4 0;

param r:=
1 20000
2 24
3 50
4 20;

param wspolczynnikReklamy:=0.1;
param procentPopytu:=0.2;
param celReklamy:=
1 2000
2 24000
3 40000;
param eps:=0.01;
param beta:=0.001;
param gamma:=1000;

param gotowka:=443000;
param kredyt:=300000;
param splacanaRata:=296000;
param jakosc:=
1 2;
param kosztJednostkowy:=
1 43648;
param cenaSprzedazy:=
1 60000;
param popyt:=277;

param N:=1;
param kosztyStale:=
1 0
2 15000;
param zdolnoscProdukcyjna:=
1 20000;
param amortyzacja:=10000;



# do modelu podajemy: jakosc, ceneSprzedazy, aktualny stan konta i koszt jednostkowy
# uwzgl?dni? prognozy rynku przy ograniczeniach na wielkoscProdukcji
# minimalizujemy ilosc wolnej gotowki

# metoda punktu odniesienia marketing vs wielkosc produkcji (Marek)

solve;
display docelowaProdukcja;
display k;
display wielkoscProdukcji;
display promocjaInternet;
display promocjaMagazyny;
display promocjaTelewizja;
display kosztyZmienne;
