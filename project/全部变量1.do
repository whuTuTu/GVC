* 2025/3/11

clear
cd "D:\CodeEconomicproject\GVC_PY"

// use .\data\风投数据\1990-2023私募通退出事件.dta,clear
// gen year = substr(退出时间,1,4)
// destring year,replace
// save .\data\风投数据\1990-2023私募通退出事件.dta,replace

**# GVC成立省份层面规模
import delimited ".\data\基金成立\GVC成立信息.csv", clear
gen Year = substr(成立时间,1,4)
destring Year 目标规模人民币百万,replace force
bysort Year 地区一级: egen IndFundSize1 = sum(目标规模人民币百万)
duplicates drop Year 地区一级,force
replace IndFundSize1 = IndFundSize1*100
replace IndFundSize1 = log(IndFundSize1)
keep Year 地区一级 IndFundSize1
sort 地区一级 Year
drop if 地区一级==""
gen Province = 地区一级
save .\input\省级层面GVC成立规模.dta,replace

**# GVC成立市级层面规模
import delimited ".\data\基金成立\GVC成立信息.csv", clear
gen Year = substr(成立时间,1,4)
destring Year 目标规模人民币百万,replace force
bysort Year 地区一级 地区二级: egen IndFundSize2 = sum(目标规模人民币百万)
duplicates drop Year 地区一级 地区二级,force
replace IndFundSize2 = IndFundSize*100
replace IndFundSize2 = log(IndFundSize2)
keep Year 地区一级 地区二级 IndFundSize2
sort 地区一级 地区二级 Year
drop if 地区二级==""
drop if Year == .
gen City = 地区二级
save .\input\市级层面GVC成立规模.dta,replace

**# 企业基本信息：地区，行业
import excel using .\data\上市公司信息\上市公司基本信息年度表\STK_LISTEDCOINFOANL.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen Year = substr(EndDate,1,4)
destring Symbol Year,replace
gen Province = PROVINCE
gen City = CITY
replace Province = "内蒙古自治区" if Province == "内蒙古"
replace Province = "宁夏回族自治区" if Province == "宁夏"
replace Province = "广西壮族自治区" if Province == "广西"
replace Province = "新疆维吾尔自治区" if Province == "新疆"
replace Province = "西藏自治区" if Province == "西藏"
gen Ind = IndustryName
keep Symbol Year Province City Ind 
save .\input\上市公司地区和行业信息.dta,replace


**# 企业代码与全称对应
import excel using .\data\上市公司信息\上市公司基本信息年度表\STK_LISTEDCOINFOANL.xlsx, firstrow clear
drop if _n == 1 | _n == 2
destring Symbol ,replace
keep Symbol FullName
duplicates drop Symbol, force
save .\input\企业代码与全称对应.dta,replace

**# 公司层面财务控制变量（CSMAR,Year,上市公司）
// 研发投入
// import excel using .\data\上市公司信息\财务报告信息-上市公司财务指标数据表\AIQ_LCFinIndexY.xlsx, firstrow clear
// drop if _n == 1 | _n == 2
// destring Symbol- IndustryName, replace
// gen RD = RDExpenses
// gen Year = substr(EndDate,1,4)
// destring Year,force replace
// keep Symbol RD Year
// save .\input\上市公司研发投入.dta,replace

// 研发投入
import excel using .\data\上市公司信息\上市公司研发创新-研发投入情况\PT_LCRDSPENDING.xlsx, firstrow clear
drop if _n == 1 | _n == 2
destring Symbol- Explanation,replace
keep if StateTypeCode == 1 // 合并会计报表
gen RD = RDSpendSum // 研发投入金额
gen RDSRatio = RDSpendSumRatio // 研发投入占营业收入比例(%)
gen Year = substr(EndDate,1,4)
destring Year,force replace
keep Symbol Year RD RDSRatio
duplicates drop Symbol Year,force
save .\input\上市公司研发投入.dta,replace

// 财务等信息
import excel using .\data\上市公司信息\企业年财务数据\智能查询_沪深京股票.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen Size = FS_CombasA001000000
gen ROA = AIQ_LCFinIndexYROTAA
gen Lev = FI_T7F070201B
gen Growth = BDT_ExcessiveDebtGrowth
gen Cash = FI_T1F010401A
gen MB = FI_T10F101001A
gen Tang = FI_T3F031001A
gen Age = BDT_FinConstFCListingAge
gen Boardsize = CG_ManagerShareSalary
gen Balance = BDT_ManaGovAbilSharesBalance
gen InsInvest = INI_HolderSystematicsInsInvesto
gen ManShare = BDT_ManaGovAbilMngmhldn
gen IndDirector = BDT_ManaGovAbilIndDirectorRatio
gen Dual = BDT_ManaGovAbilConcurrentPositi
rename EndDate Year
rename code Symbol
destring Symbol Year Size-Dual Growth,replace force
keep Symbol Year Size-Dual Growth
save .\input\上市公司财务信息.dta,replace

**# 企业专利信息
// CNRDS上市公司获得与申请情况
import excel using .\data\专利数据\CNRDS\上市公司专利获得与申请情况.xlsx, firstrow clear
keep if 公司类型=="上市公司本身"
gen PatentApply = 当年独立申请的发明数量 
gen PatentGet = 当年独立获得的发明数量
gen Year = 会计年度
gen Symbol = 股票代码
keep PatentApply PatentGet Year Symbol
save .\input\CNRDS上市公司获得与申请情况.dta,replace
// 学人师兄数据
import delimited ".\data\专利数据\学人师兄数据\上市公司专利统计.csv", clear
split stkcd,p("_")
rename stkcd2 Symbol
rename year Year
rename v3 Patent
keep Year Symbol Patent
destring Symbol, replace
save .\input\XR上市公司专利统计.dta,replace

**# 企业投资事件统计
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
replace 基金分类 = "其他基金" if 基金分类 == ""
tab 基金分类
rename year Year
gen GVC_dummy = (基金分类=="PPP" | 基金分类=="产业基金" | 基金分类=="创业投资基金" )
gen VC_dummy = (基金分类=="其他基金" )
bysort Year 企业名称: egen GVC_num = sum(GVC_dummy)
bysort Year 企业名称: egen VC_num = sum(VC_dummy)
duplicates drop 企业名称 Year , force
keep Year 企业名称 GVC_num VC_num
sort 企业名称 Year
rename 企业名称 FullName
save .\input\企业投资事件统计.dta,replace

**# 数据汇总：面板数据1_上市公司
use .\input\CNRDS上市公司获得与申请情况.dta,clear
merge 1:1 Symbol Year using .\input\XR上市公司专利统计.dta,nogen
merge m:1 Symbol using .\input\企业代码与全称对应.dta //有symbol和企业全称
keep if _merge==3
drop _merge
duplicates drop FullName Year, force
merge 1:1 FullName Year using .\input\企业投资事件统计.dta,nogen
save .\input\面板数据1_上市公司.dta,replace

**# 数据汇总：面板数据2_上市公司
use .\input\CNRDS上市公司获得与申请情况.dta,clear
merge 1:1 Symbol Year using .\input\XR上市公司专利统计.dta,nogen
merge 1:1 Symbol Year using .\input\上市公司财务信息.dta,nogen
merge 1:1 Symbol Year using .\input\上市公司研发投入.dta,nogen
merge 1:1 Symbol Year using .\input\上市公司地区和行业信息.dta,nogen
merge m:1 Province Year using .\input\省级层面GVC成立规模.dta,nogen
merge m:1 City Year using .\input\市级层面GVC成立规模.dta,nogen
egen miss = rowmiss(Size ROA Lev Growth Cash MB Tang Age Boardsize Balance InsInvest ManShare IndDirector Dual)
drop if miss > 0
drop miss
replace GVC_num=0 if GVC_num==.

 VC_num
save .\input\面板数据2_上市公司.dta,replace



