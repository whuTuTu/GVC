* 2025/3/18
clear
cd "D:\CodeEconomicproject\GVC_PY"

**# 全部企业：GVC对企业创新的影响
import delimited ".\input\面板数据_全部公司.csv", clear
// 处理变量
sort 申请人 专利year
bysort 申请人: gen num111 = _N
drop if num111<10
keep if strpos(申请人, "公司") > 0
drop 企业名称 year
rename 申请人 企业名称
rename 专利year year
rename 专利数量 Patent
// 生成DID变量
gen GVC投资次数 = 产业基金投资次数+创业投资基金投资次数+ppp基金投资次数
bysort 企业名称:egen GVC = sum(GVC投资次数) // 分组变量GVC，若公司获得政府引导基金出资成立的风投机构的投资则取
drop if GVC>1 // 删去被多次投资的企业？？
bysort 企业名称: gen post = sum(总被投资次数) // 时间变量post，为风投机构投资后哑变量，即若公司i在第t年已经获得首轮风险资本融资
replace post = 1 if post>1
gen DID = GVC*post
//winsor
winsor Patent, p(0.01) gen(Patent_x)
drop Patent
rename Patent_x Patent
// 回归
reghdfe Patent DID post, abs(企业名称 year)
 outreg2 using ./output/Table_全部企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote replace
// 平行趋势检验
bysort 企业名称:egen treat = sum(总被投资次数)
bysort 企业名称:gen treat1 = sum(总被投资次数)
replace 总被投资次数 = 0 if treat1>总被投资次数
gen RedemptionTime = .
bysort 企业名称: replace RedemptionTime = year if 总被投资次数>=1
bysort 企业名称: egen RedemptionTime1 = min(RedemptionTime)
drop RedemptionTime
rename RedemptionTime1 RedemptionTime
gen pd = year - RedemptionTime //缺失值在stata逻辑中是无线大的
sort 企业名称 year
replace pd=3 if pd>3 & pd != .
forvalues i = 3(-1)1{
	gen before_`i'=(pd==-`i'& treat ==1)
}
gen current =(pd==0&treat==1)
forvalues i = 1(1)3{
	gen after_`i'=(pd==`i'& treat ==1)
}
gen GVC_before1 = GVC*before_1
gen GVC_before2 = GVC*before_2
gen GVC_before3 = GVC*before_3
gen GVC_current = GVC*current
gen GVC_after1 = GVC*after_1
gen GVC_after2 = GVC*after_2
gen GVC_after3 = GVC*after_3
// 将风投投资之前第 ３ 年的观测值作为回归基准组
reghdfe Patent GVC_before1-GVC_after3 before_2- before_1 after_1- after_3 current, abs(企业名称 year)
 outreg2 using ./output/Table_全部企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote append 

**# 上市公司样本：GVC对创新的影响
import delimited ".\input\面板数据_全部公司.csv", clear
// 处理变量
sort 申请人 专利year
bysort 申请人: gen num111 = _N
drop if num111<10
keep if strpos(申请人, "公司") > 0
drop 企业名称 year
rename 申请人 企业名称
rename 专利year year
rename 专利数量 Patent
drop _merge
recast str255 企业名称
// 合并基金的退出数据
merge 1:m 企业名称 year using .\data\风投数据\1990-2023私募通退出事件.dta
drop if _merge==2
drop _merge
gen IPO_dummy = 1 if 退出方式 =="IPO"
bysort 企业名称: egen IPO_num =sum(IPO_dummy)
drop if IPO_num==0 | IPO_num==.
duplicates drop 企业名称 year,force
// 生成DID变量
gen GVC投资次数 = 产业基金投资次数+创业投资基金投资次数+ppp基金投资次数
bysort 企业名称:egen GVC = sum(GVC投资次数) // 分组变量GVC，若公司获得政府引导基金出资成立的风投机构的投资则取
drop if GVC>1 // 删去被多次投资的企业？？
bysort 企业名称: gen post = sum(总被投资次数) // 时间变量post，为风投机构投资后哑变量，即若公司i在第t年已经获得首轮风险资本融资
replace post = 1 if post>1
gen DID = GVC*post
//winsor
winsor Patent, p(0.01) gen(Patent_x)
drop Patent
rename Patent_x Patent
// 回归
reghdfe Patent DID post, abs(企业名称 year)
 outreg2 using ./output/Table_上市企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote replace
// 平行趋势检验
bysort 企业名称:egen treat = sum(总被投资次数)
bysort 企业名称:gen treat1 = sum(总被投资次数)
replace 总被投资次数 = 0 if treat1>总被投资次数
gen RedemptionTime = .
bysort 企业名称: replace RedemptionTime = year if 总被投资次数>=1
bysort 企业名称: egen RedemptionTime1 = min(RedemptionTime)
drop RedemptionTime
rename RedemptionTime1 RedemptionTime
gen pd = year - RedemptionTime //缺失值在stata逻辑中是无线大的
sort 企业名称 year
replace pd=3 if pd>3 & pd != .
forvalues i = 3(-1)1{
	gen before_`i'=(pd==-`i'& treat ==1)
}
gen current =(pd==0&treat==1)
forvalues i = 1(1)3{
	gen after_`i'=(pd==`i'& treat ==1)
}
gen GVC_before1 = GVC*before_1
gen GVC_before2 = GVC*before_2
gen GVC_before3 = GVC*before_3
gen GVC_current = GVC*current
gen GVC_after1 = GVC*after_1
gen GVC_after2 = GVC*after_2
gen GVC_after3 = GVC*after_3
// 将风投投资之前第 ３ 年的观测值作为回归基准组
reghdfe Patent GVC_before1-GVC_after3 before_2- before_1 after_1- after_3 current, abs(企业名称 year)
 outreg2 using ./output/Table_上市企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote append 