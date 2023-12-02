* Elemzés kezdete - Adatbázisok összeillesztése

* K�rj�k, a *** hely�re illeszd be annak a mapp�nak az el�r�si �tvonal�t, amely a let�lt�tt dta f�jlokat tartalmazza! K�sz�n�j�k!
cd *** 

use "FF3_europe.dta"

merge n:n date using "france_stock.dta"

drop if _merge==2
drop _merge


merge m:1 stock using "france_sector.dta"

drop _merge


* Felesleges adatok kiszedése

gen year=yofd(date)

drop if year==2016
drop if year==2019
drop if year==2020
drop if year==2021

* Hozam változó létrehozása

sort stock date

by stock: gen dret=log(price/price[_n-1])

* Data Cleaning

drop if dret==0 & dret[_n+1]==0 & dret[_n+2]==0 & dret[_n+3]==0 & dret[_n+4]==0

* Esemény napok létrehozása

gen day=dofd(date) 


*2018 döntő nyertek
gen event_win=0 if day==21381
replace event_win=-1 if day==21378
replace event_win=1 if day==21382
replace event_win=2 if day==21383
replace event_win=3 if day==21384

*2022 döntő vereség
gen event_loose=0 if day==22998
replace event_loose=-1 if day==22995
replace event_loose=1 if day==22999
replace event_loose=2 if day==23000
replace event_loose=3 if day==23001

sum event_win if event_win==0, detail
sum event_loose if event_loose==0, detail

* Napi hozamok leíró statisztikája az események idején
foreach i of numlist -1 0 1 2 3 {
sum dret if event_win==`i', detail
sum dret if event_loose==`i', detail
}


* Normál hozamok (FF3) számítása - ssc install rangestat

 rangestat (reg) dret SMB HML MktRF, interval(date -170 -20)  by(stock) 

* Abnormális hozamok számítása




gen AR=dret-(b_cons+b_SMB*SMB+b_HML*HML+b_MktRF*MktRF+RF)
replace AR=dret-(b_cons[_n-1]+b_SMB[_n-1]*SMB+b_HML[_n-1]*HML+b_MktRF[_n-1]*MktRF+RF) if event_win==0 | event_loose==0
replace AR=dret-(b_cons[_n-2]+b_SMB[_n-2]*SMB+b_HML[_n-2]*HML+b_MktRF[_n-2]*MktRF+RF) if event_win==1 | event_loose==1
replace AR=dret-(b_cons[_n-3]+b_SMB[_n-3]*SMB+b_HML[_n-3]*HML+b_MktRF[_n-3]*MktRF+RF) if event_win==2 | event_loose==2
replace AR=dret-(b_cons[_n-4]+b_SMB[_n-4]*SMB+b_HML[_n-4]*HML+b_MktRF[_n-4]*MktRF+RF) if event_win==3 | event_loose==3

* Normál hozamok számításának leíró statisztikája

sum b_cons, detail
sum reg_r2, detail
sum b_SMB, detail
sum b_HML, detail
sum b_MktRF, detail

sum se_cons, detail
sum reg_adj_r2, detail
sum se_SMB, detail
sum se_HML, detail
sum se_MktRF, detail

* Az abnormális hozamok statisztikai tesztje

sum AR if event_win==-1, detail
sum AR if event_loose==-1, detail
sum AR if event_win==0, detail
sum AR if event_loose==0, detail
sum AR if event_win==1, detail
sum AR if event_loose==1, detail
sum AR if event_win==2, detail
sum AR if event_loose==2, detail
sum AR if event_win==3, detail
sum AR if event_loose==3, detail

sum AR if event_win!=., detail
sum AR if event_loose!=., detail

ttest AR== 0 if event_win==-1
ttest AR== 0 if event_loose==-1
ttest AR== 0 if event_win==0
ttest AR== 0 if event_loose==0
ttest AR== 0 if event_win==1
ttest AR== 0 if event_loose==1
ttest AR== 0 if event_win==2
ttest AR== 0 if event_loose==2
ttest AR== 0 if event_win==3
ttest AR== 0 if event_loose==3

ttest AR== 0 if event_win!=.
ttest AR== 0 if event_loose!=.

sort sector
by sector: sum AR if event_win==-1, detail
by sector: sum AR if event_loose==-1, detail
by sector: sum AR if event_win==0, detail
by sector: sum AR if event_loose==0, detail
by sector: sum AR if event_win==1, detail
by sector: sum AR if event_loose==1, detail
by sector: sum AR if event_win==2, detail
by sector: sum AR if event_loose==2, detail
by sector: sum AR if event_win==3, detail
by sector: sum AR if event_loose==3, detail

by sector: sum AR if event_win!=., detail
by sector: sum AR if event_loose!=., detail

by sector: ttest AR== 0 if event_win==-1
by sector: ttest AR== 0 if event_loose==-1
by sector: ttest AR== 0 if event_win==0
by sector: ttest AR== 0 if event_loose==0
by sector: ttest AR== 0 if event_win==1
by sector: ttest AR== 0 if event_loose==1
by sector: ttest AR== 0 if event_win==2
by sector: ttest AR== 0 if event_loose==2
by sector: ttest AR== 0 if event_win==3
by sector: ttest AR== 0 if event_loose==3

by sector: ttest AR== 0 if event_win!=.
by sector: ttest AR== 0 if event_loose!=.



