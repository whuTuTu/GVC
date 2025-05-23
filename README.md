### 1.项目文件介绍

主要的结构包括【data】、【input】、【project】、【output】。

- 【data】：为原始数据。其中`风投数据`包括`1990-2023私募通退出事件.dta`和`清科和CVS投资事件和爱企查企业工商信息.dta`；`基金成立`包括`GVC成立信息.dta`；`专利数据`包括`CNRDS`和`学人师兄数据`。`上市公司信息`包括`爱企查工商信息.csv`和`上市公司工商注册号.xlsx`(投资事件没有公司股票代码一项，根据`工商登记号`进行匹配)。其余为CSMAR下载数据，大多数用作控制变量。

![image-20250521123101012](https://github.com/whuTuTu/GVC/blob/main/pic/image-20250521123101012.png)

- 【input】：用于存放数据处理中的中间生成的数据文件和合并之后的数据文件。其中`全部变量1_市级层面宏观数据.dta`是统计被投资上市公司的创新总和和市级层面GVC成立规模，`全部变量1_省级层面宏观数据.dta`是统计被投资上市公司的创新总和和省级层面GVC成立规模，`面板数据2_上市公司`公司-年面板数据，从微观层面研究GVC投资对于企业个体创新数量的影响。

- 【project】:用于存放数据处理和模型回归的文件。

  - `全部变量.do`：处理数据和合并数据。自变量1、因变量1、控制变量1、全部变量1相互对应，全部变量1为`全部变量1_市级层面宏观数据.dta`和`全部变量1_省级层面宏观数据.dta`。2同理，为`面板数据2_上市公司`。

  ![image-20250521124716902](https://github.com/whuTuTu/GVC/blob/main/pic/image-20250521124716902.png)

  `全部变量1_市级层面宏观数据.dta`和数据介绍：`Year Province`表示年份和省份，`IndFundSize1 PatentProvince1`表示省级-年份层面的GVC成立规模和被GVC投资过的全部企业（包括上市和非上市的）创新数量，`Gdp0101 Gdp0116`为宏观控制变量，代表地区生产总值和人均地区生产总值。

  `全部变量1_省级层面宏观数据.dta`数据介绍：`Year City`表示年份和城市，`PatentCity1 IndFundSize2`表示市级-年份层面的GVC成立规模和被GVC投资过的全部企业（包括上市和非上市的）创新数量。

  `面板数据2_上市公司`数据介绍：``Year、Symbol`分别代表年份和证券代码，`Patent、PatentGet、PatentApply`分别代表XR创新发明专利数量、CNRDS专利发明数量、CNRDS专利申请数量。控制变量为`ROA Growth Cash MB Tang Boardsize Balance InsInvest ManShare IndDirector Age Z SOE LMV LEV`

  - `全部图表.do`：一些描述性统计的图。

  全部企业投资次数

  ![全部企业投资次数](https://github.com/whuTuTu/GVC/blob/main/pic/%E5%85%A8%E9%83%A8%E4%BC%81%E4%B8%9A%E6%8A%95%E8%B5%84%E6%AC%A1%E6%95%B0.png)

  全部企业_根据GVC和VC分类

  ![全部企业_根据GVC和VC分类](https://github.com/whuTuTu/GVC/blob/main/pic/%E5%85%A8%E9%83%A8%E4%BC%81%E4%B8%9A_%E6%A0%B9%E6%8D%AEGVC%E5%92%8CVC%E5%88%86%E7%B1%BB.png)

  上市公司_根据GVC和VC分类

  ![上市公司_根据GVC和VC分类](https://github.com/whuTuTu/GVC/blob/main/pic/%E4%B8%8A%E5%B8%82%E5%85%AC%E5%8F%B8_%E6%A0%B9%E6%8D%AEGVC%E5%92%8CVC%E5%88%86%E7%B1%BB.png)

  全部企业_根据上市分类

  ![全部企业_根据上市分类](https://github.com/whuTuTu/GVC/blob/main/pic/%E5%85%A8%E9%83%A8%E4%BC%81%E4%B8%9A_%E6%A0%B9%E6%8D%AE%E4%B8%8A%E5%B8%82%E5%88%86%E7%B1%BB.png)

  - `DID分析.do`：使用`面板数据2_上市公司`做微观层面的GVC投资对于企业创新数量的影响，使用DID模型，平行趋势检验未完成。
  - `回归分析.do`:使用合并数据进行回归分析汇总。

### 2.目前已做工作

#### （1）省级、市级层面GVC成立规模对于被GVC投资企业发明专利总和的影响

使用`全部变量1_市级层面宏观数据.dta`和`全部变量1_省级层面宏观数据.dta`，回归模型在【project】中的`全部回归.do`

<img src="https://github.com/whuTuTu/GVC/blob/main/pic/image-20250425192011383.png" alt="image-20250425192011383" style="zoom:67%;" /><img src="https://github.com/whuTuTu/GVC/blob/main/pic/image-20250425163636039.png" alt="image-20250425163636039" style="zoom:67%;" />

#### （2）微观层面用面板数据研究企业是否被GVC投资对企业创新数量的影响

使用`面板数据2_上市公司`，回归模型在【project】中的`DID分析.do`

==步骤一：数据处理：==

参考`吴超鹏（经济研究2023）：《政府基金引导与企业核心技术突破： 机制与效应》`，对样本做以下处理：

1. 只保留首轮风险投资事件；
2. 考虑到有一部分样本虽然在首轮融 资时引进的风投机构没有政府引导基金背景，但在后续轮次可能会引入有政府引导基金背景的风 投机构，这类样本同样受到政府引导基金的影响，因此剔除这部分样本；
3. 将样本限定在创新型企业，即要求样本企业在样本期间内至少 要有一项发明专利；
4. 样本起始年份为2020年
5. 删去金融行业公司样本

==步骤二：样本分析==

- 4707个上市公司样本，有1/4被GVC投资过

<img src="https://github.com/whuTuTu/GVC/blob/main/pic/image-20250507152651876.png" alt="image-20250507152651876" style="zoom:67%;" />

- 首轮风投情况

<img src="https://github.com/whuTuTu/GVC/blob/main/pic/image-20250507152705601.png" alt="image-20250507152705601" style="zoom:67%;" />

- 被投资次数（一年被多次投资被认为是1次）

<img src="https://github.com/whuTuTu/GVC/blob/main/pic/image-20250507152717041.png" alt="image-20250507152717041" style="zoom:67%;" />

==步骤三：回归分析==

第一个回归仿照`吴超鹏（经济研究2023）：《政府基金引导与企业核心技术突破： 机制与效应》`GVC：首轮投资是否有GVC投资；Post：风投机构投资后哑变量，p =  0.112，目前控制变量基本为公司的财务变量，原文控制领头风投机构相关变量，行业集中度、行业风险程度，区域市场投资情况等变量，后续还有改进和调整的空间。

第二个回归按照以前的思路，将GVC和VC的投资分割开来。

<img src="https://github.com/whuTuTu/GVC/blob/main/pic/image-20250507152918626.png" alt="image-20250507152918626" style="zoom:67%;" />

### 3.计划未来需要继续做的工作

目前主要存在两个问题;

- 第一个回归省级层面主要回归系数为负数（与预想为正不符），可能因为存在较大的内生性。
- 第二个回归微观层面回归平行趋势检验已经描述性统计工作还需要完善。
