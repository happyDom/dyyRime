这是dyy个人使用的rime输入法配置包，基于windows和ubuntu调试通过，关于此配置在须鼠管方案下是否可用，本人没有测试。如果有人试用过，欢迎反馈补充。

本配置包包含**五笔・拼音**，**Latex**，**easyEnglish**， **pīn yīn** 四种输入方案。如果有需要在其它输入方案中配置使用某一功能，在相应的输入方案补丁文档中类比**五笔・拼音**加入相应的配置项即可。

## 版本要求
此配置包，对 **rime** 版本要求如下：
- 小狼毫（Weasel）：0.15.0.0 测试可用
- 中州韵（ibus-rime）：1.5.0-1 测试可用
- 须鼠管（Squirrel）：未测试

## 五笔・拼音
以原生**wubi_pinyin**输入方案为base，加入个性化配置的自定义输入方案，功能特性如下👇：
- 👉 智能输入时间
- 👉 智能输入日期
- 👉 智能输入农历
- 👉 智能事件提醒
- 👉 智能App表情输入
- 👉 智能Unicode符号输入
- 👉 智能联想词语
- 👉 智能词组提示
- 👉 生僻字注音提示
- 👉 中英互绎
- 👉 输入环境识别(仅测试了window环境下的功能是正常的)
- 👉 敏感词脱敏功能
- 👉 runLog lua脚本日志功能
- 👉 定制化表情顺序

## LaTex
这是一个自己配置的用于辅助输入`LaTex`公式的输入方案，可以辅助输入一些基础的数学公式，但并未完全支持所有的`LaTex`公式。

## **easyEnglish**
这是 `Patrick <ipatrickmac@gmail.com>` 提供的英文单词输入方案，在此仅做了少量的个性化配置，基本保持了原生输入方案的功能和样式。

## pīn yīn
这是一个自己配置并实现的用于输入汉语拼音的输入方案，基于一年级女儿提供的拼音注音规律，通过一个`lua_translator`实现的拼音输入方案。

## 配置教程
与本仓库配合的，面向零基础的，由浅入深的教程专栏：[小狼毫 Rime 保姆教程](http://t.csdnimg.cn/tsXn3) 

## 功能效果欣赏

- 👇 中文(五笔)输入, 英文(easy-english)输入, latex输入  
  ![20231228195526](https://s2.loli.net/2023/12/28/r3eXPsy2iABYRon.png)
  - 单词首字母大写  
    ![20240103193948](https://s2.loli.net/2024/01/03/ntOGQr6qkC7jWKT.png)  
  
  - 中英互译：中译英  
    ![20240103193426](https://s2.loli.net/2024/01/03/l1IcyuLiMk9AS8n.png)
  
  - 中英互译：英译中
    ![20240103193655](https://s2.loli.net/2024/01/03/dUtMeATlbKXZ8ug.png)
  
  - 汉语拼音输入  
    ![20240113013722](https://raw.githubusercontent.com/happyDom/dyyPicGo/main/20240113013722.png)

- 👇 正常文本中临时输入 latex 基本字符  
  ![20231229155452_rec_](https://s2.loli.net/2023/12/29/9VXLwmyI6fNRjr3.gif)

- 👇 程序环境个性化定制效果  
  ![20231228200432](https://s2.loli.net/2023/12/28/Loku8s75n6mdc1z.png)

- 👇 自定义输入框  
  ![20231228195718](https://s2.loli.net/2023/12/28/GctzXDQOM5VldZm.png)

- 👇 自定义符号效果  
  ![20231228192612](https://s2.loli.net/2023/12/28/gcUZB2qn34SQAWa.png)
  
  - 👇 状态机选项，推荐指数，进度条，对错勾叉符号  
    ![20231228193007](https://s2.loli.net/2023/12/28/bo1KEaGwiQ8u9rq.png)
  
  - 👇 上标数字/文字，下标数字/文字  
    ![20231228194202](https://s2.loli.net/2023/12/28/KEqiV1rBtQsz6cL.png)
  
  - 👇 罗马数字，大写罗马数字，带点的数字，带括号的数字，苏州码字  
    ![20231228193508](https://s2.loli.net/2023/12/28/PnwZ8RLD3dbs6tj.png)
  
  - 👇 带圈数字，中文数字，带圈中文数字，括号中文数字，分数符号  
    ![20231228193849](https://s2.loli.net/2023/12/28/seG1c69Xba8Th2j.png)
  
  - 👇 干支编码，星座与符号，节气  
    ![20240103195239](https://s2.loli.net/2024/01/03/gnmjKqhleY1MuF3.png)
  
  - 👉 希腊字母，汉字注音
    ![20240103195544](https://s2.loli.net/2024/01/03/zhwL13MY6rWPUvN.png)

  - 👇 按钮图标，汉字部首  
    ![20231228195110](https://s2.loli.net/2023/12/28/zpTx6oPtFbDfsin.png)  

- 👇 日期/时间效果  
  - 👇 当前时间, 时辰,钟表符号  
    ![20231228200848](https://s2.loli.net/2023/12/28/1b4wZgQ95xrVNY3.png)
  
  - 👇 日期输入效果,今天,明天,昨天,后天,前天  
    ![20231228201130](https://s2.loli.net/2023/12/28/1hmdl5HVEfUb7ow.png)
  
  - 👇 周序 与 星期  
    - 👇 本周,下周,上周  
      ![20231228201424](https://s2.loli.net/2023/12/28/uL2M7WaAqPsImYk.png)

    - 👇 周一 至 周日  
      ![20231228201919](https://s2.loli.net/2023/12/28/rO4HKRTQxjfEhda.png)
  
  - 👇 月份 与 年  
    - 👇 本月，上月，下月  
      ![20231228202350](https://s2.loli.net/2023/12/28/lDfFbpSa2XWoQIB.png)

    - 👇 今年，去年，明年  
      ![20231228202544](https://s2.loli.net/2023/12/28/zbYdcwXhpKPCUo3.png)

- 👇 农历 与 节气  
  - 👇 农历/节气  
    ![20231228202751](https://s2.loli.net/2023/12/28/XEgNv9yFOS3ctjo.png)
  
  - 👇 春分 至 大寒  
    ![20231228203520](https://s2.loli.net/2023/12/28/eTM43R1wV2soFzf.png)

- 👇 动态信息显示/生成效果  
  - 👇 生成uuid，显示 ip，随机密码  
  ![20231228203814](https://s2.loli.net/2023/12/28/LVuQzego2r4X7jx.png)

  - 👇 系统信息显示效果  
    ![20231228204044](https://s2.loli.net/2023/12/28/K1il5ZPraJxwSns.png)

- 👇 自定义短语效果  
  - 👇 emoji输入效果  
    - 👇 微信定制emoji输入  
      ![20231229155822_rec_](https://s2.loli.net/2023/12/29/vtnkBxToyKhmD5g.gif)

    - 👇 钉钉定制emoji输入  
      ![20231229160458_rec_](https://s2.loli.net/2023/12/29/QqvxAhSyeMkE4L6.gif)

    - 👇 unicode emoji符号输入  
      ![20231229160826_rec_](https://s2.loli.net/2023/12/29/HBb7Q64SNTG5iPn.gif)

  - 👇 单位换算效果  
    ![20231229161058_rec_](https://s2.loli.net/2023/12/29/N9b6fpJVFWDurmt.gif)

  - 👇 常用git命令输入  
    ![20231229165301_rec_](https://s2.loli.net/2023/12/29/2RW3CtiGElLIwob.gif)

  - 👇 常用python关键字输入  
    ![20231229165632_rec_](https://s2.loli.net/2023/12/29/mcRkqaezgEJQKB3.gif)

- 👇 词条备注效果  
  - 👇 化学元素提示  
    ![20231229170132](https://s2.loli.net/2023/12/29/JvwLRs96eKzd8ZY.png)

  - 👇 五笔编码提示  
    ![20231229170327](https://s2.loli.net/2023/12/29/psLQWui17Zo6GvM.png)

  - 👇 车牌提示  
    ![20231229170805](https://s2.loli.net/2023/12/29/RBfLSZPGy81Qsoz.png)

- 👇 敏感词过滤效果  
    ![20231229171830](https://s2.loli.net/2023/12/29/VcX3NeviYbHgm2G.png)

- 👇 生词注音效果  
    ![20231229172530](https://s2.loli.net/2023/12/29/J9eHWtp65PQ1Iun.png)

- 👇 help效果  
  ![20231229095414](https://s2.loli.net/2023/12/29/eIhJsRYj7BkTzH8.png)

- 👇 latex输入效果  
  ![20231229095742](https://s2.loli.net/2023/12/29/Yt8xQiFy1GOLANa.png)

  - 👇 help效果  
    ![20231229111604](https://s2.loli.net/2023/12/29/uFrHxDEGXtAqNJ6.png)

  - 👇 彩色文本效果  
    ![20231229105359_rec_](https://s2.loli.net/2023/12/29/TfCK5M4u7y21ZIj.gif)  
    ![20231229105628_rec_](https://s2.loli.net/2023/12/29/3c9i8jesXSaF2fr.gif)

  - 👇 上标下标输入效果  
    ![20231229153319_rec_](https://s2.loli.net/2023/12/29/m4OEwRvCUXFfGsu.gif)

  - 👇 希腊字母输入效果  
    ![20231229152447_rec_](https://s2.loli.net/2023/12/29/X3A1U4FDnfTPyLZ.gif)

  - 👇 箭头输入效果  
    ![20231229152809_rec_](https://s2.loli.net/2023/12/29/zK7dGwIsOx5qQHn.gif)

  - 👇 三角函数, 反三角函数  
    ![20231229115100_rec_](https://s2.loli.net/2023/12/29/tsZ7LTUq1cnogOS.gif)  
    ![20231229115523_rec_](https://s2.loli.net/2023/12/29/LmVAanw2e65uisT.gif)

  - 👇 双曲函数,反双曲函数  
    ![20231229115907_rec_](https://s2.loli.net/2023/12/29/8KglYwyneBHdqrV.gif)  
    ![20231229120145_rec_](https://s2.loli.net/2023/12/29/8NfIyBdMvcozPTQ.gif)

  - 👇 分数输入  
    ![20231229153815_rec_](https://s2.loli.net/2023/12/29/P5wW86JeZt4HMIm.gif)

  - 👇 微商输入  
    ![20231229113043_rec_](https://s2.loli.net/2023/12/29/TPJbUp15XwmKq8V.gif)
  
  - 👇 积分输入  
    ![20231229121109_rec_](https://s2.loli.net/2023/12/29/HVUNmQCfRP5uaE1.gif)  
    ![20231229121837_rec_](https://s2.loli.net/2023/12/29/HbvtwOApT9oWJGB.gif)

  - 👇 对数输入  
    ![20231229122242_rec_](https://s2.loli.net/2023/12/29/HWRTJXKcGmrqyaE.gif)

  - 👇 极限输入效果  
    ![20231229144812_rec_](https://s2.loli.net/2023/12/29/iKfAXgP24tpOzHq.gif)

  - 👇 点输入效果  
    ![20231229145153_rec_](https://s2.loli.net/2023/12/29/jDmQLK1sZUxPt5d.gif)

  - 👇 `abs` 绝对值输入，`bar` 上划线输入  
    ![20231229150227_rec_](https://s2.loli.net/2023/12/29/VZkCTXJsijrgQSd.gif)  
    ![20231229150335_rec_](https://s2.loli.net/2023/12/29/YLv8x2rI13BCuoX.gif)
  
  - 👇 开方输入效果  
    ![20231229150855_rec_](https://s2.loli.net/2023/12/29/vdWe8Qi3tIaqPfM.gif)

  - 👇 临域符号输入效果  
    ![20231229152246_rec_](https://s2.loli.net/2023/12/29/L64pNE52YmHDgtK.gif)

  - 👇 函数样式  
    ![20231229154249_rec_](https://s2.loli.net/2023/12/29/mSeD5KhbNCfH64q.gif)

  - 👇 其它输入效果  
    ![20231229173451_rec_](https://s2.loli.net/2023/12/29/UKxZFAhsdSQWB9I.gif)  
    ![20231229173706_rec_](https://s2.loli.net/2023/12/29/CkIlqjKvu8F4nN6.gif)  
    ![20231229174205_rec_](https://s2.loli.net/2023/12/29/3efCKj7WSGR8cHU.gif)  
    ![20231229174327_rec_](https://s2.loli.net/2023/12/29/YW2HcIZ3GysOg1K.gif)
