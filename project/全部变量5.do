* 2025/5/7
clear
cd "D:\CodeEconomicproject\GVC_PY"

**# 自变量1：GVC成立省份和市级层面规模
// 省级层面
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
save .\input\自变量1_省级层面GVC成立规模.dta,replace
// 市级层面
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
save .\input\自变量1_市级层面GVC成立规模.dta,replace

**# 自变量2：企业投资事件
// 企业代码与全称对应
import excel using .\data\上市公司基本信息年度表\STK_LISTEDCOINFOANL.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen Year = substr(EndDate,1,4)
destring Symbol Year,replace
keep Symbol Year SocialCreditCode
duplicates drop SocialCreditCode,force
save .\input\企业代码与社会信用代码对应.dta, replace
// 企业代码与工商注册号
import excel using .\data\上市公司信息\上市公司工商注册号.xlsx, firstrow clear
drop if 公司发行证券一览证券类型股票交易市场全部 == "--"
split 公司发行证券一览证券类型股票交易市场全部,p("),")
drop  公司发行证券一览证券类型股票交易市场全部5 公司发行证券一览证券类型股票交易市场全部6 公司发行证券一览证券类型股票交易市场全部7 公司发行证券一览证券类型股票交易市场全部8 公司发行证券一览证券类型股票交易市场全部9 公司发行证券一览证券类型股票交易市场全部10
gen 股票信息 = 公司发行证券一览证券类型股票交易市场全部4 if strpos(公司发行证券一览证券类型股票交易市场全部4,"A股")
drop 公司发行证券一览证券类型股票交易市场全部4
replace 股票信息 = 公司发行证券一览证券类型股票交易市场全部3 if strpos(公司发行证券一览证券类型股票交易市场全部3,"A股")
drop 公司发行证券一览证券类型股票交易市场全部3
replace 股票信息 = 公司发行证券一览证券类型股票交易市场全部2 if strpos(公司发行证券一览证券类型股票交易市场全部2,"A股")
drop 公司发行证券一览证券类型股票交易市场全部2
replace 股票信息 = 公司发行证券一览证券类型股票交易市场全部1 if strpos(公司发行证券一览证券类型股票交易市场全部1,"A股")
drop 公司发行证券一览证券类型股票交易市场全部1
drop if 股票信息 == ""
drop 公司发行证券一览证券类型股票交易市场全部
split 股票信息,p(",")
split 股票信息1,p("(")
split 股票信息3,p(")")
keep 工商登记号 股票信息11 股票信息12 股票信息31 
rename 股票信息11 证券简称
rename 股票信息12 Symbol
rename 股票信息31 交易所
destring Symbol,replace
duplicates drop 工商登记号,force
save .\input\企业代码和工商登记号.dta,replace
// 企业投资事件
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
replace 基金分类 = "其他基金" if 基金分类 == ""
tab 基金分类
rename year Year
gen GVC_dummy = (基金分类=="PPP" | 基金分类=="产业基金" | 基金分类=="创业投资基金" )
gen VC_dummy = (基金分类=="其他基金" )
bysort Year 企业名称: egen GVC_num = sum(GVC_dummy)
bysort Year 企业名称: egen VC_num = sum(VC_dummy)
duplicates drop 企业名称 Year, force
gen SocialCreditCode = 统一社会信用代码
keep Year 企业名称 GVC_num VC_num 工商注册号
sort 企业名称 Year
rename 企业名称 FullName
rename 工商注册号 工商登记号
merge m:1 工商登记号 using .\input\企业代码和工商登记号.dta
keep if _merge == 3
drop _merge
save .\input\自变量2_企业投资事件统计.dta,replace

**# 因变量2：企业专利信息
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
// 合并两个专利数据
use .\input\CNRDS上市公司获得与申请情况.dta,clear
merge 1:1 Symbol Year using .\input\XR上市公司专利统计.dta,nogen
sum Patent PatentApply PatentGet 
save .\input\因变量2_企业专利数据.dta,replace

**# 因变量2：研发投入
// 研发投入
import excel using .\data\上市公司研发创新-研发投入情况\PT_LCRDSPENDING.xlsx, firstrow clear
drop if _n == 1 | _n == 2
destring Symbol- Explanation,replace
keep if StateTypeCode == 1 // 合并会计报表
gen RD = RDSpendSum // 研发投入金额
gen RDSRatio = RDSpendSumRatio // 研发投入占营业收入比例(%)
gen Year = substr(EndDate,1,4)
destring Year,force replace
keep Symbol Year RD RDSRatio
duplicates drop Symbol Year,force
save .\input\因变量2_上市公司研发投入.dta,replace

**# 因变量1：宏观层面被投资的企业专业之和
// 省级层面统计专利数据(被GVC投资过企业)
import delimited ".\input\省份层面创新数量.csv", clear
rename 专利数量 PatentProvince1
rename 所属省份 Province
rename year Year
sort Province Year
drop if Province=="-"
save .\input\因变量1_省级层面被GVC投资企业专利统计.dta,replace
// 市级层面统计专利数据(被GVC投资过企业)
import delimited ".\input\市级层面创新数量.csv", clear
rename 专利数量 PatentCity1
rename 所属省份 Province
rename 所属城市 City
rename year Year
sort Province City Year
drop if Province=="-"
drop if City == "上海市"
replace City = "上海市"  if City == "市辖区"
duplicates drop Year City,force
save .\input\因变量1_市级层面被GVC投资企业专利统计.dta,replace

**# 控制变量1
// 投资层面？
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
drop if 查询名称=="匹配分数＜15"
rename year Year
gen Ind2001= 行业分类2001
gen SocialCreditCode = 统一社会信用代码
gen FullName = 企业名称
keep Year SocialCreditCode FullName Ind2001 round_num1- round_num29
sort FullName Year
duplicates drop FullName Year,force
save .\input\控制变量1_投资轮次和2001年公司行业分类.dta,replace
// 省份GDP
use ./data/上市公司信息/宏观控制变量/CRE_Gdp01.dta,clear
rename year Year
rename firm_province Province
save .\input\控制变量1_省份GDP.dta,replace

**# 控制变量2
// EstablishYear
import excel using .\data\治理结构-基本数据-公司基本情况文件\CG_Co.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen EstablishYear = substr(EstablishDate,1,4)
rename Stkcd Symbol
destring Symbol EstablishYear,replace
keep Symbol EstablishYear
duplicates drop Symbol,force
save .\input\EstablishYear.dta,replace
// 财务变量
import excel using .\data\企业年财务数据\智能查询_沪深京股票.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen ROA = AIQ_LCFinIndexYROTAA
gen Growth = BDT_ExcessiveDebtGrowth
gen Cash = FI_T1F010401A
gen MB = FI_T10F101001A
gen Tang = FI_T3F031001A
gen Boardsize = CG_ManagerShareSalary
gen Balance = BDT_ManaGovAbilSharesBalance
gen InsInvest = INI_HolderSystematicsInsInvesto
gen ManShare = BDT_ManaGovAbilMngmhldn
gen IndDirector = BDT_ManaGovAbilIndDirectorRatio
gen Dual = BDT_ManaGovAbilConcurrentPositi
rename EndDate Year
rename code Symbol
destring Symbol Year ROA- Dual,replace force
replace Growth = Growth*100
merge m:1 Symbol using .\input\EstablishYear.dta
drop if _merge == 2
drop _merge
gen Age = Year-EstablishYear+1
keep Symbol Year ROA- Dual Age
save .\input\控制变量2_上市公司财务信息.dta,replace

// Z值
import excel using .\data\联表_财务困境ZScore模型_被分析师关注度\BDT_FinDistZScore.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen Symbol = BDT_FinDistZScoreSymbol
gen Z = BDT_FinDistZScoreZScore
gen Year = substr(BDT_FinDistZScoreEnddate,1,4)
destring Symbol Year Z,replace
keep Symbol Year Z 
save .\input\控制变量2_上市公司Z值.dta,replace
// 企业属性
import excel using .\data\股权性质-中国上市公司股权性质文件\EN_EquityNatureAll.xlsx, firstrow clear
drop if _n == 1 | _n == 2
destring EquityNatureID Symbol,replace
gen SOE = (EquityNatureID=="1")
keep Symbol SOE
duplicates drop Symbol,force
save .\input\控制变量2_SOE.dta,replace
// 市值LMV
import excel using .\data\财务指标分析-相对价值指标\FI_T10.xlsx, firstrow clear
drop if _n == 1 | _n == 2
rename Stkcd Symbol
split Accper,p("-")
destring Symbol Accper1-Accper3 F100801A,replace
rename Accper1 Year
keep if Accper2 == 12
gen LMV = ln(F100801A/100000000)
keep Symbol Year LMV
save .\input\控制变量2_市值LMV,replace
// 杠杆率LEV
import excel using .\data\经营困境-非效率投资\BDT_InefficInvest.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen Year = substr(Enddate,1,4)
gen LEV = FinLeverageRatio
keep Symbol Year LEV
destring Symbol Year LEV,replace
duplicates drop Symbol Year,force
save .\input\控制变量2_杠杆率LEV,replace
// 2001行业和2012行业
import excel using .\data\治理结构-基本数据-公司基本情况文件\CG_Co.xlsx, firstrow clear
drop if _n == 1 | _n == 2
rename Stkcd Symbol
keep Symbol Nnindnme-Nindcd
destring Symbol,replace
save .\input\控制变量2_2001行业和2012行业.dta,replace
// 公司停牌
import excel using .\data\因子研究系列-股票流动性-个股停牌标识表-全部代码\LIQ_SUSPENSION.xlsx, firstrow clear
drop if _n == 1 | _n == 2
keep if ST == "Y"
rename Stkcd Symbol
gen Year = substr(Suspdate,1,4)
keep Symbol Year ST
destring Symbol Year,replace force
duplicates drop Symbol Year,force
save .\input\控制变量2_企业ST信息.dta,replace

**# 其他变量
**# 企业退出事件
use ./data/风投数据/1990-2023私募通退出事件.dta, clear
gen str244 fund = 退出方全称 
gen str244 firm = 企业名称
sort fund firm
rename year Exit_Year
duplicates drop fund firm Exit_Year,force
gen Year = substr(首次投资时间,1,4)
destring Year,replace
sort fund firm Year
duplicates examples fund firm Year
duplicates drop fund firm Year,force
keep fund firm Year Exit_Year 退出方式
drop if Year==.
save .\input\退出事件1.dta,replace

use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
replace 基金分类 = "其他基金" if 基金分类 == ""
tab 基金分类
rename year Year
gen GVC_dummy = (基金分类=="PPP" | 基金分类=="产业基金" | 基金分类=="创业投资基金" )
gen VC_dummy = (基金分类=="其他基金" )
gen str244 fund_str = fund 
gen str244 firm_str = firm
drop fund firm
rename fund_str fund
rename firm_str firm
duplicates drop fund firm Year,force
merge 1:1 fund firm Year using .\input\退出事件1.dta
gen Exit_dummy = 1 if _merge == 3
drop if _merge==2
drop _merge

gen SocialCreditCode = 统一社会信用代码
sort 企业名称 Year
rename 企业名称 FullName
rename 工商注册号 工商登记号
merge m:1 工商登记号 using .\input\企业代码和工商登记号.dta
keep if _merge == 3
drop _merge

keep Symbol firm Year fund GVC_dummy VC_dummy Exit_Year Exit_dummy 退出方式
gen InvestPeriod = Exit_Year-Year
drop if InvestPeriod<0
sum InvestPeriod
sum InvestPeriod if GVC_dummy == 1
sum InvestPeriod if VC_dummy == 1
count if GVC_dummy == 1
count if VC_dummy == 1
count if Exit_dummy == 1

sort firm Year
save .\input\投资事件层面_投资和退出事件.dta,replace

use .\input\投资事件层面_投资和退出事件.dta,clear
keep if Exit_dummy==1
duplicates drop Symbol Year GVC_dummy VC_dummy Exit_Year,force
sort Symbol Year GVC_dummy VC_dummy Exit_Year
save .\input\投资事件层面_投资和退出事件2.dta,replace

**# 全部变量1：省级和市级层面宏观数据
// 省级层面
use .\input\自变量1_省级层面GVC成立规模.dta,clear
merge 1:1 Year Province using .\input\因变量1_省级层面被GVC投资企业专利统计.dta,nogen
merge 1:1 Year Province using .\input\控制变量1_省份GDP.dta
keep if _merge == 3
drop _merge
keep Province Year IndFundSize1 PatentProvince1 Gdp0101 Gdp0116
sum 
save .\input\全部变量1_省级层面宏观数据.dta,replace
// 市级层面
use .\input\自变量1_市级层面GVC成立规模.dta,clear
merge 1:1 Year City using .\input\因变量1_市级层面被GVC投资企业专利统计.dta,nogen
merge m:1 Year Province using .\input\控制变量1_省份GDP.dta
keep if _merge == 3
drop _merge
keep Province City Year IndFundSize2 PatentCity1 Gdp0101 Gdp0116
sum 
save .\input\全部变量1_市级层面宏观数据.dta,replace

**# 全部变量2：企业层面的投资事件与创新数据
use .\input\因变量2_企业专利数据.dta,clear
drop if Year<2000
replace Patent=0 if Patent==.
bysort Symbol: egen Patent_Sum = sum(Patent)
drop if Patent_Sum == 0 // 将样本限定在创新型企业，即要求样本企业在样本期间内至少要有一项发明专利
drop Patent_Sum

merge 1:1 Symbol Year using .\input\因变量2_上市公司研发投入.dta,nogen

merge 1:1 Symbol Year using .\input\自变量2_企业投资事件统计.dta
drop if _merge == 2
drop _merge

merge 1:1 Symbol Year using .\input\控制变量2_上市公司财务信息.dta
drop if _merge == 2
drop _merge

merge 1:1 Symbol Year using .\input\控制变量2_上市公司Z值.dta
drop if _merge == 2
drop _merge

merge m:1 Symbol using .\input\控制变量2_SOE.dta
drop if _merge == 2
drop _merge

merge 1:1 Symbol Year using .\input\控制变量2_市值LMV.dta
drop if _merge == 2
drop _merge

merge 1:1 Symbol Year using .\input\控制变量2_杠杆率LEV.dta
drop if _merge == 2
drop _merge

merge m:1 Symbol using .\input\控制变量2_2001行业和2012行业.dta
drop if _merge == 2
drop _merge
gen Ind = substr(Nindcd,1,1) // 删去金融行业
drop if Ind == "J"

// 只保留首轮风投事件
replace GVC_num=0 if GVC_num==.
replace VC_num=0 if VC_num==.
gen GVC_dummy = (GVC_num>0)
gen VC_dummy = (VC_num>0)
tab GVC_dummy VC_dummy

gen Invest_dummy = GVC_dummy+VC_dummy // 是否被投资
replace Invest_dummy=1 if Invest_dummy>1
bysort Symbol: gen Invest_num111 = sum(Invest_dummy)
bysort Symbol: gen Invest_num222 = sum(Invest_num111)
gen FirstInvest = (Invest_num222==1) // 首轮投资
gen FirstInvesttype = 1 if GVC_dummy==1 & VC_dummy==0 & FirstInvest==1 // 首轮风投为GVC
replace FirstInvesttype = 2 if GVC_dummy==0 & VC_dummy==1 & FirstInvest==1
replace FirstInvesttype = 3 if GVC_dummy==1 & VC_dummy==1 & FirstInvest==1
replace FirstInvesttype = 0 if FirstInvest==0
tab FirstInvesttype if FirstInvest==1
drop Invest_num111 Invest_num222
drop GVC_num VC_num

// 删去首轮投资为VC，后续被GVC投资的企业
bysort Symbol: egen GVC_num = sum(GVC_dummy) // 企业样本期内一共被投资多少年次
bysort Symbol: egen VC_num = sum(VC_dummy)
gen GVC_treat = (GVC_num>0)
gen VC_treat = (VC_num>0)
bysort Symbol: egen FirstInvesttype111 = max(FirstInvesttype)
drop if FirstInvesttype111 == 2 & GVC_treat == 1 // 删去首轮投资为VC，后续被GVC投资的企业

// egen miss = rowmiss(ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Dual Age Z SOE LMV LEV)
// drop if miss > 0
// drop miss

// sum Patent PatentApply PatentGet ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV

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
save .\input\面板数据2_上市公司.dta,replace




