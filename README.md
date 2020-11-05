# 硕士研究生在线选导师系统 Tutor Recruit System
+ 版本列表
    * 20201105
    * 20201104
    * 20170912

+ 一、数据库配置
    数据库部署到服务器后，创建一个登录名 `TutorRecruitSys`，密码为 `HgggXds@87114057`，配置如下用户映射：数据库 `TutorRecruitSys`，用户 `TutorRecruitSys`，默认架构 `dbo`，权限为 `db_owner`、`public`。

+ 二、系统配置
    * 1.配置本系统数据库地址：修改 `/inc/config.inc` 中 `uriDatabaseServer` 的值
    * 2.配置教务系统数据库地址：修改 `/inc/config.inc` 中 `uriJWDatabaseServer` 的值，默认为 `116.57.68.162,14033`

+ 三、系统入口
    * 1.教务端：`/?usertype=admin`（以 `ouyangquan` 身份登录）
    * 2.学生端：`/?usertype=student&no=XXX`（XXX为学生学号）
    * 3.教师端：`/?usertype=tutor&name=XXX`（XXX为教师账号）