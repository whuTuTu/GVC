* 2025/4/8
clear
cd "D:\CodeEconomicproject\GVC_PY"

**# 一些数据分析
// 4707个上市公司样本，有1/4被GVC投资过
use .\input\面板数据2_上市公司.dta,clear
duplicates drop Symbol,force
tab GVC_treat VC_treat
// 首轮风投情况(0-无;1-GVC;2-VC;3-Both)
tab FirstInvesttype111 

// 被投资次数
use .\input\面板数据2_上市公司.dta,clear
tab GVC_num
tab VC_num

**# 上市企业：DID回归，GVC投资对企业创新的影响
use .\input\面板数据2_上市公司.dta,clear
local Control ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV
// 首轮风投有GVC投资的影响，参考吴超鹏：政府基金引导与企业核心技术突破： 机制与效应（经济研究2023），控制变量不一样
gen GVC111 = (FirstInvesttype==1 | FirstInvesttype==3) // 首轮投资是否有GVC
bysort Symbol: egen GVC = max(GVC111)
gen Invest111 = (FirstInvesttype==1 | FirstInvesttype==2 | FirstInvesttype==3) 
bysort Symbol: gen Post = sum(Invest111) // 风投机构投资后哑变量
gen GVC_Post = GVC*Post
reghdfe Patent GVC_Post Post $Control, abs(Symbol Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Symbol", "Yes" ,"Year","Yes") adjr2 nonote replace
// 用GVC_DID和VC_DID分开估计效应
use .\input\面板数据2_上市公司.dta,clear
local Control ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV
gen GVC111 = (FirstInvesttype==1) // 首轮投资是否只有GVC
bysort Symbol: egen GVC = max(GVC111)
bysort Symbol: gen Post1 = sum(GVC111) 
gen GVC_DID = GVC*Post1
gen VC111 = (FirstInvesttype==2) // 首轮投资是否只有GVC
bysort Symbol: egen VC = max(VC111)
bysort Symbol: gen Post2 = sum(VC111)
gen VC_DID = VC*Post2
gen Both111 = (FirstInvesttype==3) // 首轮投资是否GVC和VC都有
bysort Symbol: egen Both = max(Both111)
bysort Symbol: gen Post3 = sum(Both111)
gen Both_DID = VC*Post3

reghdfe Patent GVC_DID VC_DID Both_DID $Control, abs(Symbol Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Symbol", "Yes" ,"Year","Yes") adjr2 nonote append

**# 描述性统计
// unconditional
use .\input\面板数据2_上市公司.dta,clear
tabstat ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV, by(FirstInvesttype) stats(mean sd) format(%6.2f) c(s)
logout, save(output/summary01) excel replace: tabstat ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV, by(FirstInvesttype) s(mean sd) f(%6.2f) c(s)
// normdiff ROA if FirstInvesttype==0 | FirstInvesttype==1, over(FirstInvesttype)
use .\input\面板数据2_上市公司.dta,clear
gen TREATED = 1 if FirstInvesttype==1
replace TREATED = 0 if FirstInvesttype==0
logout, save(output/summary02) excel replace: ttestplus ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV,by(TREATED) 
drop TREATED
gen TREATED = 1 if FirstInvesttype==2
replace TREATED = 0 if FirstInvesttype==0
logout, save(output/summary03) excel replace: ttestplus ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV,by(TREATED) 
drop TREATED
gen TREATED = 1 if FirstInvesttype==3
replace TREATED = 0 if FirstInvesttype==0
logout, save(output/summary04) excel replace: ttestplus ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV,by(TREATED) 

// conditional
use .\input\面板数据2_上市公司.dta,clear
gen TREATED = 1 if FirstInvesttype==2
replace TREATED = 0 if FirstInvesttype==0
cor ROA Growth Balance InsInvest Age SOE LMV LEV
local Control ROA Growth Balance InsInvest Age SOE LMV LEV

**# 平行趋势检验
use .\input\面板数据2_上市公司.dta,clear
local Control ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV
gen GVC111 = (FirstInvesttype==1 | FirstInvesttype==3) // 首轮投资是否有GVC
bysort Symbol: egen GVC = max(GVC111)
bysort Symbol: gen Post1 = sum(GVC111) 
gen GVC_DID = GVC*Post1
gen VC111 = (FirstInvesttype==2 | FirstInvesttype==3) // 首轮投资是否有GVC
bysort Symbol: egen VC = max(VC111)
bysort Symbol: gen Post2 = sum(VC111)
gen VC_DID = VC*Post2

// 生成时间变量GVCInvestTime
bysort Symbol: gen GVCInvestTime = Year if GVC111 == 1
gen GVC111_fu  = -GVC111
bysort Symbol(Symbol GVC111_fu): replace GVCInvestTime = GVCInvestTime[_n-1] if missing(GVCInvestTime)
drop GVC111_fu

//生成政策时点前后期数
gen pd = Year - GVCInvestTime //缺失值在stata逻辑中是无线大的
sort Symbol Year
replace pd=-5 if pd<-5
// drop if pd<-5
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
reghdfe Patent pre_5- pre_2 current las_1- las_5 pre_1 VC_DID , abs(Year Symbol)
 outreg2 using ./output/Table_平行趋势检验.rtf, tstat bdec(3) tdec(2) addtext("Symbol", "Yes" ,"Year","Yes") adjr2 nonote replace // pre_1会被omitted掉
est sto reg
coefplot,baselevels omitted keep(pre* current las*) vertical recast(connect) order(pre_5 pre_4 pre_3 pre_2 pre_1 current las_1 las_2 las_3 las_4 las_5) yline(0,lp(solid) lc(black)) xline(5,lp(solid)) ytitle("企业GVC对创新的影响") xtitle("GVC投资时点") xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5") ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) 

**# did_multiplegt
did_multiplegt_dyn Patent Symbol Year GVC_DID, effects(6) placebo(4) controls($Control VC_DID) cluster(Symbol) 
event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("时期") ytitle("平均处理效应") xlabel(-5(1)5) name(dCdH, replace)) stub_lag(Effect_#) stub_lead(Placebo_#) together shift(1)