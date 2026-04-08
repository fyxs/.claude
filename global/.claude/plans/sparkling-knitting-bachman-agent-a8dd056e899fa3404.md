# Web端需求描述文档获取与保存计划

## 已获取的内容

通过 agent-browser 访问语雀文档，获取到以下需求描述内容：

### 1. 巡检路线

**页面路由：**
- 新增页：`inspection-management/inspection-route-add`
- 编辑页：`inspection-management/inspection-route-add`【与新增页共用】

**需求描述：**
新增页、编辑页增加【开启方式】配置项：
1. 三种方式：1、手动开启 2、扫码开启 3、NFC开启（暂不支持IOS设备）
2. 必填，默认选择手动开启
3. 手动开启与扫码开启、NFC开启为互斥，即选中手动开启，则扫码开启、NFC自动清空；选中扫码开启、NFC开启，则手动开启自动清空。扫码开启、NFC开启可同时选中
4. 【开启方式】表单项标签后方增加问号，鼠标移入后tooltip提示"手动开启与扫码开启、NFC开启不可同时选择"

**备注：** 放在巡检责任人配置项下面

**接口：**
在已有接口 `inspection/route/insert` 下新加字段 `openModeList`
- `openModeList`：List<String>，开启方式，枚举范围：MANUAL 标识手动开启，SCAN_CODE 标识扫码开启，NFC 表示NFC开启；选择手动时，后两者清空并禁用

---

### 2. 巡检路线详情页

**页面路由：**
- 巡检路线列表页：`inspection-management/inspection-route`
- 巡检路线详情页：`inspection-management/inspection-route-view`

**需求描述：**
详情页增加开启方式回显字段，接口字段提供具体的文案，前端无需转换。

**备注：** 开启方式字段放在兜底人员右侧，与兜底人员并列一排

**接口：**
在已有接口 `inspection/task/getDetail` 下新加字段 `openModeName`
- `openModeName(3.15.0新增)`：String，开启方式

---

### 3. 巡检任务详情页

**页面路由：**
- 巡检任务列表页：`inspection-management/inspection-task-list`
- 巡检任务详情页：`inspection-management/inspection-task-detail`

**需求描述：** （文档内容未完全加载）

---

### 4. 巡检管理配置

**页面路由：** 待查看

**需求描述：** （文档内容未完全加载）

---

## 保存路径

根据项目规则，文档应保存到：
- 项目计划目录：`D:\2Work\Claude\ts-projects\nts-eam-front\.claude\plans\`

## 下一步行动

1. 将获取到的需求文档内容保存到 `.claude\plans\web端需求描述-NFC巡检.md`
2. 继续获取"巡检任务详情页"和"巡检管理配置"的完整需求描述
