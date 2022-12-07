local L = AceLibrary("AceLocale-2.2"):new("FuXP")

L:RegisterTranslations("enUS", function() return {
	["AceConsole-commands"] = { "/FuXPFu" },

	["Colors"] = true,
	["Set the Bar Colors"] = true,

	["Bar Properties"] = true,
	["Set the Bar Properties"] = true,

	["Current XP"] = true,
	["Sets the color of the XP Bar"] = true,

	["Rested XP"] = true,
	["Sets the color of the Rested Bar"] = true,

	["No XP"] = true,
	["Sets the empty color of the XP Bar"] = true,
	
	["Rep"] = true,
	["Sets the color of the Rep Bar"] = true,
	
	["No Rep"] = true,
	["Sets the empty color of the Rep Bar"] = true,

	["Show XP Bar"] = true,
	["Show the XP Bar"]  = true,
	
	["Show Rep Bar"] = true,
	["Show the Rep Bar"] = true,

	["Spark intensity"] = true,
	["Brightness level of Spark"] = true,

	["Thickness"] = true,
	["Sets thickness of XP Bar"] = true,

	["Shadow"] = true,
	["Toggles Shadow under the bottommost bar"] = true,

	["Remaining"] = true,
	["Show Remaining in Bar"] = true,

	["Select faction to watch"] = true,
	["Faction"] = true,
	
	["Watched Faction"] = true,

	["Undocked position"] = true,
	["Selects which side of an undocked panel you want the bars on."] = true,

	["%s: %3.0f%% (%s/%s)  (%s)"] = true,
	["%s: %3.0f%% (%s/%s)  (%s) // XP: %3.0f%%/%s to go"] = true,
	["%s  (%s) // XP: %3.0f%%/%s to go"] = true,
	["XP: %3.0f%%/%s to go"] = true,

	["Current XP"] = true,
	["To level"] = true,
	["Rested XP"] = true,
	["Click to send your current xp to an open editbox."] = true,
	["Shift Click to send your current rep to an open editbox."] = true,
	["Faction"] = true,
	["Reputation to next standing"] = true,
	["Current standing"] = true,

	["Top"] = true, 
	["Bottom"] = true,
	["XP"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["AceConsole-commands"] = { "/FuXPFu" },

	["Colors"] = "색상",
	["Set the Bar Colors"] = "바의 색상을 설정합니다",

	["Bar Properties"] = "표시 내용",
	["Set the Bar Properties"] = "바의 표시 내용을 설정합니다",

	["Current XP"] = "현재 경험치",
	["Sets the color of the XP Bar"] = "현재 경험치 바의 색상을 설정합니다",

	["Rested XP"] = "휴식 경험치",
	["Sets the color of the Rested Bar"] = "휴식 경험치 바의 색상을 설정합니다",

	["No XP"] = "남은 경험치",
	["Sets the empty color of the XP Bar"] = "남은 경험치 바의 색상을 설정합니다",
	
	["Rep"] = "평판",
	["Sets the color of the Rep Bar"] = "평판바의 색상을 설정합니다",
	
	["No Rep"] = "남은 평판",
	["Sets the empty color of the Rep Bar"] = "남은 평판바의 색상을 설정합니다",

	["Show XP Bar"] = "경험치바 표시",
	["Show the XP Bar"]  = "경험치 바를 표시합니다",
	
	["Show Rep Bar"] = "평판바 표시",
	["Show the Rep Bar"] = "평판바를 표시합니다",

	["Spark intensity"] = "구분선",
	["Brightness level of Spark"] = "구분선의 밝기 정도를 설정합니다",

	["Thickness"] = "굵기",
	["Sets thickness of XP Bar"] = "경험치바의 굵기를 설정합니다",

	["Shadow"] = "음영",
	["Toggles Shadow under the bottommost bar"] = "경험치 바 하단의 그림자를 토글합니다",

	["Remaining"] = "잔상",
	["Show Remaining in Bar"] = "바에 잔상 표시합니다.",

	["Select faction to watch"] = "진영 선택",
	["Faction"] = "진영",
	
	["Watched Faction"] = "표시중인 평판",

	["Undocked position"] = "패널분리시 위치",
	["Selects which side of an undocked panel you want the bars on."] = "패널을 분리 하였을 경우 패널의 어느쪽에 바를 표시할지를 선택합니다.",

	["%s: %3.0f%% (%s/%s) %s left"] = "%s 진영: %3.0f%% (%s/%s) %s 남았음",

	["Current XP"] = "현재 경험치",
	["To level"] = "남은 경험치",
	["Rested XP"] = "휴식 경험치",
	["Click to send your current xp to an open editbox."] = "클릭시 입력창이 열려 있을 경우 현재 경험치를 출력합니다.",
	["Shift Click to send your current rep to an open editbox."] = "Shift 클릭시 입력창이 열려 있을 경우 현재 평판을 출력합니다.",
	["Faction"] = "진영",
	["Reputation to next standing"] = "다음 단계까지 남은 평판",
	["Current rep"] = "현재 평판",

	["Top"] = "위", 
	["Bottom"] = "아래",
	["XP"] = "경험치"	,
} end)

L:RegisterTranslations("zhTW", function() return {
	["AceConsole-commands"] = { "/FuXPFu" },

	["Colors"] = "顏色",
	["Set the Bar Colors"] = "設定經驗/聲望條顏色",

	["Bar Properties"] = "屬性",
	["Set the Bar Properties"] = "設定經驗/聲望條屬性",

	["Current XP"] = "現在經驗",
	["Sets the color of the XP Bar"] = "設定現在經驗顏色",

	["Rested XP"] = "獎勵經驗",
	["Sets the color of the Rested Bar"] = "設定獎勵經驗顏色",

	["No XP"] = "空白經驗條",
	["Sets the empty color of the XP Bar"] = "設定空白經驗條顏色",
	
	["Rep"] = "現在聲望",
	["Sets the color of the Rep Bar"] = "設定現在聲望顏色",
	
	["No Rep"] = "空白聲望條",
	["Sets the empty color of the Rep Bar"] = "設定空白聲望條顏色",

	["Show XP Bar"] = "顯示經驗條",
	["Show the XP Bar"]  = "顯示經驗條",
	
	["Show Rep Bar"] = "顯示聲望條",
	["Show the Rep Bar"] = "顯示聲望條",

	["Spark intensity"] = "分界亮度",
	["Brightness level of Spark"] = "設定現在值與剩餘值分界標誌的亮度",

	["Thickness"] = "厚度",
	["Sets thickness of XP Bar"] = "設定經驗/聲望條的厚度",

	["Shadow"] = "陰影效果",
	["Toggles Shadow under the bottommost bar"] = "開啟經驗/聲望條的陰影效果",

	["Remaining"] = "顯示剩餘值",
	["Show Remaining in Bar"] = "在經驗/聲望條顯示剩餘值",

	["Select faction to watch"] = "選擇陣營",
	["Faction"] = "陣營",
	
	["Watched Faction"] = "監察的陣營",

	["Undocked position"] = "附著位置",
	["Selects which side of an undocked panel you want the bars on."] = "設定經驗/聲望條附著在面板的哪一側",

	["%s: %3.0f%% (%s/%s) %s left"] = "%s: %3.0f%% (%s/%s) 尚欠: %s",

	["Current XP"] = "現在經驗",
	["To level"] = "升級需要經驗",
	["Rested XP"] = "獎勵經驗",
	["Click to send your current xp to an open editbox."] = "\n|cffeda55f左擊: |r向聊天輸入框發送經驗值。",
	["Shift Click to send your current rep to an open editbox."] = "|cffeda55fShift-左擊: |r向聊天輸入框發送聲望值。",
	["Faction"] = "陣營",
	["Reputation to next standing"] = "提升聲望等級需要聲望",
	["Current rep"] = "現在聲望",

	["Top"] = "頂部", 
	["Bottom"] = "底部",
	["XP"] = "經驗",
} end)

L:RegisterTranslations("frFR", function() return {
	["AceConsole-commands"] = { "/FuXPFu" },

	["Colors"] = "Couleurs",
	["Set the Bar Colors"] = "D\195\169finit les couleurs de la barre",

	["Bar Properties"] = "Propri\195\169t\195\169s",
	["Set the Bar Properties"] = "Change les propri\195\169t\195\169s de la barre",

	["Current XP"] = "XP actuelle",
	["Sets the color of the XP Bar"] = "Choisit la couleur de la barre d'exp\195\169rience",

	["Rested XP"] = "XP en repos",
	["Sets the color of the Rested Bar"] = "Choisit la couleur de la barre d'XP repos\195\169",

	["No XP"] = "Exp\195\169rience - Vide",
	["Sets the empty color of the XP Bar"] = "Choisit la couleur de la partie vide de la barre d'exp\195\169rience",
	
	["Rep"] = "R\195\169putation",
	["Sets the color of the Rep Bar"] = "Choisit la couleur de la barre de r\195\169putation",
	
	["No Rep"] = "R\195\169putation - Vide",
	["Sets the empty color of the Rep Bar"] = "Choisit la couleur de la partie vide de la barre de r\195\169putation",

	["Show XP Bar"] = "Afficher la barre d'exp\195\169rience",
	["Show the XP Bar"]  = "Affiche la barre d'exp\195\169rience",
	
	["Show Rep Bar"] = "Afficher la barre de r\195\169putation",
	["Show the Rep Bar"] = "Affiche la barre de r\195\169putation",

	["Spark intensity"] = "Intencit\195\169 de l'\195\169tincelle",
	["Brightness level of Spark"] = "R\195\168gle l'intensit\195\169 de l'\195\169tincelle sur la barre d'exp\195\169rience",

	["Thickness"] = "Epaisseur",
	["Sets thickness of XP Bar"] = "R\195\168gle l'\195\169paisseur de la barre d'XP",

	["Shadow"] = "Ombrage",
	["Toggles Shadow under the bottommost bar"] = "Active/d\195\169sactive l'ombrage de la barre d'XP",

	["Remaining"] = "Restant",
	["Show Remaining in Bar"] = "Afficher l'XP restante pour ce niveau dans la barre",

	["Select faction to watch"] = "S\195\169lectionne la faction",
	["Faction"] = "Faction",
	
	["Watched Faction"] = "Faction monitor\195\169e",

	["Undocked position"] = "Position",
	["Selects which side of an undocked panel you want the bars on."] = "Choisit de quel cot\195\169 d'un panneau libre vous voulez les barres",

	["%s: %3.0f%% (%s/%s) %s left"] = "%s: %3.0f%% (%s/%s) %s restant",

	["Current XP"] = "XP actuelle",
	["To level"] = "Jusqu'au niveau",
	["Rested XP"] = "XP repos\195\169",
	["Click to send your current xp to an open editbox."] = "Cliquer pour ins\195\169rer votre XP actuelle dans une fen\195\170tre de discussion",
	["Shift Click to send your current rep to an open editbox."] = "Maj-Clic pour ins\195\169rer votre r\195\169putation actuelle dans une fen\195\170tre de discussion",
	["Faction"] = "Faction",
	["Reputation to next standing"] = "R\195\169putation jusqu'au prochain palier",
	["Current rep"] = "R\195\169putation actuelle",

	["Top"] = "Haut", 
	["Bottom"] = "Bas",
	["XP"] = "XP",
} end)

L:RegisterTranslations("zhCN", function() return {
--Simplified Chinese by Diablohu
--last update: 7/22/07
--http://www.dreamgen.cn
	["AceConsole-commands"] = { "/FuXPFu" },

	["Colors"] = "颜色",
	["Set the Bar Colors"] = "设置经验值/声望值条颜色",

	["Bar Properties"] = "属性",
	["Set the Bar Properties"] = "设置经验值/声望值条属性",

	["Current XP"] = "当前经验值",
	["Sets the color of the XP Bar"] = "设置当前经验值条颜色",

	["Rested XP"] = "休息奖励经验值",
	["Sets the color of the Rested Bar"] = "设置休息奖励经验值条颜色",

	["No XP"] = "经验值条背景",
	["Sets the empty color of the XP Bar"] = "设置经验值条背景颜色",
	
	["Rep"] = "声望值",
	["Sets the color of the Rep Bar"] = "设置声望值条颜色",
	
	["No Rep"] = "声望值条背景",
	["Sets the empty color of the Rep Bar"] = "设置声望值条背景颜色",

	["Show XP Bar"] = "显示经验值条",
	["Show the XP Bar"] = "显示经验值条",
	
	["Show Rep Bar"] = "显示声望值条",
	["Show the Rep Bar"] = "显示声望值条",

	["Spark intensity"] = "游标亮度",
	["Brightness level of Spark"] = "设置游标亮度",

	["Thickness"] = "高度",
	["Sets thickness of XP Bar"] = "设置经验值/声望值条高度",

	["Shadow"] = "阴影",
	["Toggles Shadow under the bottommost bar"] = "是否显示阴影",

	["Remaining"] = "剩余值",
	["Show Remaining in Bar"] = "在 FuBar 上显示经验/声望的剩余值",

	["Select faction to watch"] = "选择阵营",
	["Faction"] = "阵营",
	
	["Watched Faction"] = "关注的阵营",

	["Undocked position"] = "依附位置",
	["Selects which side of an undocked panel you want the bars on."] = "选择声望值/经验值条在该 FuBar 条的哪一侧显示",

	["%s: %3.0f%% (%s/%s) %s left"] = "%s: %3.0f%% (%s/%s) 尚欠%s",

	["Current XP"] = "当前经验值",
	["To level"] = "升级仍需",
	["Rested XP"] = "休息奖励",
	["Click to send your current xp to an open editbox."] = "单击将你的当前经验值信息发送到聊天输入框",
	["Shift Click to send your current rep to an open editbox."] = "Shift-单击将你的当前声望值信息发送到聊天输入框",
	["Faction"] = "阵营",
	["Reputation to next standing"] = "到达下一关系需要",
	["Current rep"] = "当前关系",

	["Top"] = "上", 
	["Bottom"] = "下",
	["XP"] = "经验",
} end)
