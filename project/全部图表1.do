* 2025/4/4
clear
cd "D:\CodeEconomicproject\GVC_PY"

**# 投资情况
// 投资次数
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
rename year Year
drop if Year < 2000
bysort Year: gen 全部企业年投资总次数 = _N
drop if firm_exchange == ""
bysort Year: gen 上市公司年投资总次数 = _N 
duplicates drop Year,force
twoway (bar 全部企业年投资总次数 Year) (bar 上市公司年投资总次数 Year), ///
		ytitle("年投资总次数") ///
		legend(label(1 "投资全部企业") label(2 "投资上市公司") position(6))
graph export .\output\全部企业投资次数.png, replace width(800) height(400)

// 全部企业:根据GVC和VC分类
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
rename year Year
drop if Year < 2000 | Year == .
replace 基金分类 = "其他基金" if 基金分类 == ""
tab 基金分类
gen GVC_Dummy = (基金分类 != "其他基金")
gen VC_Dummy = (基金分类 == "其他基金")
bysort Year: gen 全部企业年投资总次数 = _N
bysort Year: egen GVC_num = sum(GVC_Dummy)
bysort Year: egen VC_num = sum(VC_Dummy)
duplicates drop Year,force
gen GVC_ratio = GVC_num/全部企业年投资总次数
gen VC_ratio = VC_num/全部企业年投资总次数
keep Year GVC_ratio VC_ratio GVC_num VC_num 全部企业年投资总次数
sort Year
graph bar GVC_ratio VC_ratio, ///
    stack over(Year, label(angle(90))) ///
    legend(label(1 "GVC占比") label(2 "VC占比") position(6)) ///
    ytitle("投资占比") bar(1, color("255 153 153")) bar(2, color("155 194 230")) ///
    graphregion(color(white)) ///
    aspectratio(0.5) ///
    blabel(bar, position(outside) angle(90) color(black) format(%9.2f)) ///
graph export .\output\全部企业_根据GVC和VC分类.png, replace width(800) height(400)

// 上市公司:根据GVC和VC分类
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
drop if firm_exchange==""
rename year Year
drop if Year < 2000 | Year == .
replace 基金分类 = "其他基金" if 基金分类 == ""
tab 基金分类
gen GVC_Dummy = (基金分类 != "其他基金")
gen VC_Dummy = (基金分类 == "其他基金")
bysort Year: gen 全部企业年投资总次数 = _N
bysort Year: egen GVC_num = sum(GVC_Dummy)
bysort Year: egen VC_num = sum(VC_Dummy)
duplicates drop Year,force
gen GVC_ratio = GVC_num/全部企业年投资总次数
gen VC_ratio = VC_num/全部企业年投资总次数
keep Year GVC_ratio VC_ratio GVC_num VC_num 全部企业年投资总次数
sort Year
graph bar GVC_ratio VC_ratio, ///
    stack over(Year, label(angle(90))) ///
    legend(label(1 "GVC占比") label(2 "VC占比") position(6)) ///
    ytitle("投资占比") bar(1, color("255 153 153")) bar(2, color("155 194 230")) ///
    graphregion(color(white)) ///
    aspectratio(0.5) ///
    blabel(bar, position(outside) angle(90) color(black) format(%9.2f)) 
graph export .\output\上市公司_根据GVC和VC分类.png, replace width(800) height(400)

// 根据上市和非上市分类
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
rename year Year
drop if Year < 2000 | Year == .
tab firm_exchange
gen noexchange_Dummy = (firm_exchange == "")
gen exchange_Dummy = (firm_exchange != "")
gen China_exchange_Dummy =  strpos(firm_exchange, "上海") > 0 | strpos(firm_exchange, "深圳") > 0 | strpos(firm_exchange, "香港") > 0 | strpos(firm_exchange, "全国") > 0
gen Foreign_exchange_Dummy =  strpos(firm_exchange, "东京") > 0 | strpos(firm_exchange, "伦敦") > 0 | strpos(firm_exchange, "新加坡") > 0 | strpos(firm_exchange, "纽约") > 0 | strpos(firm_exchange, "法兰克福") > 0  | strpos(firm_exchange, "澳大利亚") > 0 | strpos(firm_exchange, "纳斯达克") > 0 | strpos(firm_exchange, "苏黎世证") > 0 |strpos(firm_exchange, "韩国") > 0 |strpos(firm_exchange, "多伦多") > 0
bysort Year: gen 全部企业年投资总次数 = _N
bysort Year: egen noexchange_num = sum(noexchange_Dummy)
bysort Year: egen exchange_num = sum(exchange_Dummy)
bysort Year: egen China_exchange_num = sum(China_exchange_Dummy)
bysort Year: egen Foreign_exchange_num = sum(Foreign_exchange_Dummy)
duplicates drop Year,force
gen noexchange_ratio = noexchange_num/全部企业年投资总次数
gen exchange_ratio = exchange_num/全部企业年投资总次数
gen China_exchange_ratio = China_exchange_num/全部企业年投资总次数
gen Foreign_exchange_ratio = Foreign_exchange_num/全部企业年投资总次数
keep Year noexchange_ratio exchange_ratio China_exchange_ratio Foreign_exchange_ratio 
sort Year
graph bar noexchange_ratio exchange_ratio , ///
    stack over(Year, label(angle(90))) ///
    legend(label(1 "非上市公司占比") label(2 "上市占比") position(6)) ///
    ytitle("投资占比") ///
    graphregion(color(white)) ///
    aspectratio(0.5) ///
    blabel(bar, position(outside) angle(90) color(black) format(%9.2f))
	graph export .\output\全部企业_根据上市分类.png, replace width(800) height(400)
	
// 