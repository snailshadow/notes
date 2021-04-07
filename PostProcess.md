# PostProcess

## 1. 简介

	### 1.1 逻辑视图

1. 根据通信代码（service code），该过程处理输入数据，执行验证，格式化
2. 将来自处理和通信的自定义数据（UDF）添加到导出，执行定义的计算并创建结果导出集。
3. 出口通过HC SAS ADP进一步传递到渠道。 然后，它再次通过HC SAS ADP接收并处理响应数据。

### 1.2 物理视图

1. 这是一个接收标准通信输出（SAS数据集），输入定义（来自CDM数据库）和来自autoexec的配置的过程。 
2. 该过程执行已定义的逻辑并将结果导出数据保存到CDM数据库。 通过与HC SAS集成，ADP（Web服务）传输导出的数据。

 <img src="https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210322141301.png" alt="image-20210322141259631" style="zoom:100%;" />

### 1.3 包含的组件

1. -存储过程（以下称为STP）-PostProcess
2. -STP-Response Integration
3. -STP-Set Status
4. -SAS Maker-Custom Validation
5. -CDM数据库-带有前缀CIE_的表集
6. -配置-appserver_autoexec_usermods.sas

## 2.后处理的各个步骤

​	PostProcess由两部分组成，CV（Custom Validation ）和自定义PostProcess STP

### 2.1 CV(Custom Validation)

​	加载输入数据，执行验证，格式化，执行特定的业务逻辑并准备要导出的数据。

#### 2.1.1 确定业务环境并检索有关活动的信息

​	PostProcess支持处理多个业务上下文（以下称为BC）。 BC设置位于CIE_MST表的CDM数据库中（以下仅称为CDM）。
​	另外，在此步骤中，从CDM检索标准活动信息（表CI_CELL_PACKAGE，CI_COMMUNICATION，CI_CAMPAIGN）。

#### 2.1.2 从元数据中检索活动信息

PostProcess使用SAS®MA Integration Utilities检索有关活动和相关对象的数据。

- Treatment data
- Campaign UDF data
- Communication UDF data

#### 2.1.3 Export initialization

1. 在CDM中创建正在进行执行的记录（CDM.CIE_INT_EXECUTION）。
2. Empty export check. 对于给定的Service Code campaign，可以设置是否允许空导出。 如果未启用空导出，则导出将中止，执行状态为NOT_VALID。
3. 检查有效的“服务x主题”组合（CDM设置。CIE_INTM_Service_Subject），该逻辑在MA_post_insert_exec到MA_post_expabsence_chck宏中实现。

#### 2.1.4 处理默认的导出数据集
1. 第一步，对导出的数据进行格式化和数据转换。

2. 从数据中删除控制组（CELL_CNTRL_GRP_FLAG导出中的参数名称）。将检查导出的数据在包含导出主题的标识符的字段中不包含重复项（在CDM.CIE_MST.SUBJECT_KEY中设置）。该逻辑在MA_post_exp_data_conversion到MA_post_down_grade_attr宏中实现。

3. 细分产生，细分的创建取决于广告系列的类型（服务代码）。

   

PostProcess可让您处理以下活动：

- 创建新的导出
- 更新已执行的导出
- 取消已经执行的导出
  服务代码在CDM中的CIE_INTM_SERVICE中设置。

export segmenty 

​	为每个响应跟踪代码（以下称为RTC）创建一个细分，并将相应的主题插入其中。 导出集中的参数名称为A_RTC。

#### 2.1.5 validate export 属性

根据导出定义执行检查，该导出定义是为每个通道（或服务代码）设置的，并且位于CIE_INTM_SIGNATUREITEM表的CDM DB中。该逻辑在MA_post_header_chck宏中实现。

执行的检查：

- 检查SUBJECT级别的属性是否存在（来自SAS MA通信的标准导出的数据）
- 检查处理UDF属性是否存在（出口级别SEGMENT）
- 检查广告活动和通讯的UDF属性是否存在（出口级别EXECUTION）
- 检查属性是否具有填充值（遵循CDM设置.CIE_INTM_SIGNATUREITEM.NULLACCEPTED_FLAG）

#### 2.1.6 创建导出表和自定义逻辑
在此步骤中，将创建导出表（SAS数据集，参数值表结构）。该表填充了所有级别（执行，分段和主题）的属性数据。 对于EXECUTION和SEGMENT级别的属性，将根据配置执行自定义逻辑（请参见下面的ADDON）。

PostProcess允许您实现自定义逻辑，该自定义逻辑将在活动，通信和处理（执行和段导出级别）的属性上执行。

- 通过实现SAS宏（以下称为ADDON宏）来执行自定义
- ADDON宏可用于设置属性的值（计算，从数据库读取，映射，快捷方式等）
- 在CDM表中为必需的导出属性注册了ADDON宏。 CIE_INTM_SIGNATUREITEM.ADDON_MACRONAME

该逻辑在MA_post_UDF_export到MA_post_CDM_export和MA_post_addon_call宏中实现。

#### 2.1.7 完成export 准备
检查导出的数据是否已定义数据类型和填充值。 根据检查结果，将导出的数据分为一组有效和无效的导出数据。
进行检查以查看有效数据集是否不为空。 如果未启用空导出（CDM设置。CIE_INTM_Service。Enabled_EmptyExport），则导出将中止，执行状态为NOT_VALID。

所有有效出口记录的数量均写入CDM数据库。 对于CDM数据库，表CIE_INT_EXECUTION：

- PRIMARY_EXPORT_COUNT，标准SAS MA导出的记录
- EXPORTED_SUBJECTS_COUNT，postprocess导出到通道的有效记录数
  广告系列执行状态设置为“VALIDATED”。
  逻辑位于MA_Set_Status宏的MA_post_record_chck中。

