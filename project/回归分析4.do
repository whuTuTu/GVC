* 2025/4/8
clear
cd "D:\CodeEconomicproject\GVC_PY"

**# 描述性统计
use .\input\面板数据2_上市公司.dta,clear
sum Patent PatentApply PatentGet ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV
hist Patent
count if Patent==0

count if PatentApply==0
display 20204/39248

count if PatentGet==0
display 23186/39248

**# 省级层面回归
use .\input\全部变量1_省级层面宏观数据.dta,clear
drop if Year<2000
replace IndFundSize1 = 0 if IndFundSize1==.
sum 
reghdfe PatentProvince1 IndFundSize1 Gdp0116 Gdp0101, abs(Year)
 outreg2 using ./output/Table_省份层面.rtf, tstat bdec(3) tdec(2) addtext("Year","Yes") adjr2 nonote replace
reghdfe PatentProvince2 IndFundSize1 Gdp0116 Gdp0101, abs(Year)
 outreg2 using ./output/Table_省份层面.rtf, tstat bdec(3) tdec(2) addtext("Year","Yes") adjr2 nonote append
reghdfe PatentProvince3 IndFundSize1 Gdp0116 Gdp0101, abs(Year)
 outreg2 using ./output/Table_省份层面.rtf, tstat bdec(3) tdec(2) addtext("Year","Yes") adjr2 nonote append
 
**# 市级层面回归
use .\input\全部变量1_市级层面宏观数据.dta,clear
replace IndFundSize2 = 0 if IndFundSize2==.
reghdfe PatentCity1 IndFundSize2 Gdp0116 Gdp0101, abs(Year)
 outreg2 using ./output/Table_市级层面.rtf, tstat bdec(3) tdec(2) addtext("Year","Yes") adjr2 nonote replace
reghdfe PatentCity2 IndFundSize2 Gdp0116 Gdp0101, abs(Year)
 outreg2 using ./output/Table_市级层面.rtf, tstat bdec(3) tdec(2) addtext("Year","Yes") adjr2 nonote append
reghdfe PatentCity3 IndFundSize2 Gdp0116 Gdp0101, abs(Year)
 outreg2 using ./output/Table_市级层面.rtf, tstat bdec(3) tdec(2) addtext("Year","Yes") adjr2 nonote append
  
**# 上市企业：DID回归，GVC投资对企业创新的影响
use .\input\面板数据2_上市公司.dta,clear
// replace Patent=0 if Patent==.

// // 删去没有创新的行业
// bysort Ind: egen sumpatent = sum(Patent)
// tab Ind if sumpatent == 0
// drop if sumpatent == 0
// drop sumpatent
// // 删去没有创新的公司
// bysort Symbol: egen sumpatent = sum(Patent)
// drop if sumpatent == 0
// drop sumpatent

// winsor
local vv "ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z LMV LEV RD Patent PatentGet PatentApply"
     foreach v of varlist `vv'{
    winsor `v', p(0.01) gen(`v'_x)
    drop `v'
    rename `v'_x `v'
     }
foreach var of varlist _all {
	label var `var' ""
}

// 控制变量
sort Symbol Year
gen LNRD = ln(RD)
local Control ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV

// 生成Treat和Post
bysort Symbol:egen GVC_treat = sum(GVC_num) // 分组变量GVC，若公司获得政府引导基金出资成立的风投机构的投资则取1
replace GVC_treat = 1 if GVC_treat>1
bysort Symbol:egen VC_treat = sum(VC_num) // 分组变量VC，若公司获得普通基金出资成立的风投机构的投资则取1
replace VC_treat = 1 if VC_treat>1
bysort Symbol(Symbol Year):gen GVC_sum = sum(GVC_num)
bysort Symbol(Symbol Year):gen VC_sum = sum(VC_num) 
bysort Symbol(Symbol Year):egen GVC_min = min(GVC_sum)
bysort Symbol(Symbol Year):egen VC_min = min(VC_sum)
gen GVC_post = (GVC_sum>GVC_min) 
gen VC_post = (VC_sum>VC_min) 
gen DID_GVC = GVC_treat*GVC_post
gen DID_VC = VC_treat*VC_post
drop GVC_sum VC_sum GVC_min VC_min

// 对照组处理
bysort Symbol:gen num111 = _N 
drop if num111<20 & GVC_treat == 0 //除去对照组中的年份缺失太多的组别
drop num111

// 回归
reghdfe Patent DID_GVC DID_VC $Control, abs(Symbol Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Symbol", "Yes" ,"Year","Yes") adjr2 nonote replace
reghdfe PatentApply DID_GVC DID_VC $Control, abs(Symbol Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Symbol", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe PatentGet DID_GVC DID_VC $Control, abs(Symbol Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Symbol", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe LNRD DID_GVC DID_VC $Control, abs(Symbol Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Symbol", "Yes" ,"Year","Yes") adjr2 nonote append

// 被GVC多次投资 
gen GVC_dummy = (GVC_num>0)
// bysort Symbol:egen GVC_sum = sum(GVC_dummy)
// duplicates drop Symbol,force //查看公司被几次GVC投资
// tab GVC_sum
drop if GVC_dummy > 1 // 被多次投资的不知道怎么处理

// 平行趋势检验
// 生成时间变量GVCInvestTime
bysort Symbol: gen GVCInvestTime = Year if GVC_dummy == 1
gen GVC_dummy_fu  = -GVC_dummy
bysort Symbol(Symbol GVC_dummy_fu): replace GVCInvestTime = GVCInvestTime[_n-1] if missing(GVCInvestTime)
drop GVC_dummy_fu

//生成政策时点前后期数
gen pd = Year - GVCInvestTime //缺失值在stata逻辑中是无线大的
sort Symbol Year
// replace pd=-5 if pd<-5
drop if pd<-5
replace pd=5 if pd>5 & pd != .
// 平行趋势
forvalues i = 5(-1)1{
	gen pre_`i'=(pd==-`i'& GVC_treat ==1)
}
gen current =(pd==0&GVC_dummy==1)
forvalues i = 1(1)5{
	gen las_`i'=(pd==`i'& GVC_treat ==1)
}
// replace pre_1=0 if pre_1==1
sort Symbol Year
reghdfe Patent pre_5- pre_2 current las_1- las_5 pre_1 DID_VC $Control, abs(Year Symbol)
 outreg2 using ./output/Table_平行趋势检验.rtf, tstat bdec(3) tdec(2) addtext("Symbol", "Yes" ,"Year","Yes") adjr2 nonote replace // pre_1会被omitted掉
est sto reg
coefplot,baselevels omitted keep(pre* current las*) vertical recast(connect) order(pre_5 pre_4 pre_3 pre_2 pre_1 current las_1 las_2 las_3 las_4 las_5) yline(0,lp(solid) lc(black)) xline(5,lp(solid)) ytitle("企业GVC对创新的影响") xtitle("GVC投资时点") xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5") ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) 

**# did_multiplegt
did_multiplegt_dyn Patent Symbol Year DID_GVC, effects(6) placebo(4) controls($Control DID_VC) cluster(Symbol) 
event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("时期") ytitle("平均处理效应") xlabel(-5(1)5) name(dCdH, replace)) stub_lag(Effect_#) stub_lead(Placebo_#) together shift(1)
