-- Dev Menu 外观适配器，用于 CoA / Esteria 客户端（由 Esteria 外观定义生成）。
-- 每个选项为 (字段, 数量, 系数)：字段值 += 选择 * 系数。
-- 字段 1-5 是 5 个标准外观字节（皮肤、面部、发型、发色、胡须）；6 及以上通过“extra”传输。
-- 客户端不存在的种族不会被提供，因此本文件在其它客户端上不会产生副作用。
-- 汉化：lrrry 2026-11-12
--By lrrry 2026-11-12
--End By lrrry
local T = {}
T["66:0"] = { {1,5,1,"Face"}, {0,9,1,"Skin Color"}, {2,10,1,"Horn Style"}, {2,2,90,"Horn Markings"}, {2,9,10,"Beard"}, {1,9,5,"Hair"}, {0,26,9,"Eye Color"}, {3,4,64,"Body Paint"}, {5,3,1,"Body Paint Color"}, {3,8,1,"Foremane"}, {1,5,45,"Nose Piercing"}, {5,3,3,"Headdress"}, {4,4,1,"Horn Wraps"}, {3,8,8,"Horn Decoration"}, {4,4,4,"Tail Decoration"}, {5,3,9,"Tail"}, {5,1,1,"Jewelry Color"}, {5,3,27,"Feather"}, {4,4,16,"Horn Color"}, {4,4,64,"Eyesight"}, {5,3,81,"Eye Style"} }
T["66:1"] = { {1,4,1,"Face"}, {0,9,1,"Skin Color"}, {2,9,1,"Hair"}, {0,26,9,"Eye Color"}, {2,9,9,"Horn Style"}, {5,2,3,"Horn Markings"}, {3,7,1,"Foremane"}, {3,5,7,"Earrings"}, {1,4,4,"Body Paint"}, {2,3,81,"Body Paint Color"}, {5,2,6,"Feather"}, {1,4,16,"Hair Decoration"}, {5,1,1,"Jewelry Color"}, {1,4,64,"Nose Piercing"}, {4,3,64,"Headdress"}, {5,2,12,"Horn Wraps"}, {5,2,24,"Horn Decoration"}, {4,4,1,"Horn Color"}, {5,2,48,"Tail"}, {3,5,35,"Tail Decoration"}, {4,4,4,"Necklace"}, {4,4,16,"Eyesight"}, {5,3,1,"Eye Style"} }
T["68:0"] = { {0,14,1,"Skin Color"}, {1,10,1,"Face"}, {2,11,1,"Hair Style"}, {3,14,1,"Hair Color"}, {4,11,1,"Beard Style"}, {0,14,14,"Gem Color"}, {3,14,14,"Eye Color"}, {1,4,10,"Eyesight"}, {1,2,40,"Eyebrows"}, {5,2,25,"Belt"}, {2,5,11,"Right Shoulder"}, {4,5,11,"Left Shoulder"}, {2,3,55,"Torso"}, {5,5,1,"Arms"}, {4,3,55,"Legs"}, {5,5,5,"Hands"} }
T["69:0"] = { {0,14,1,"Skin Color"}, {1,10,1,"Face"}, {2,11,1,"Hair Style"}, {3,14,1,"Hair Color"}, {4,11,1,"Beard Style"}, {0,14,14,"Gem Color"}, {3,14,14,"Eye Color"}, {1,4,10,"Eyesight"}, {1,2,40,"Eyebrows"}, {5,2,25,"Belt"}, {2,5,11,"Right Shoulder"}, {4,5,11,"Left Shoulder"}, {2,3,55,"Torso"}, {5,5,1,"Arms"}, {4,3,55,"Legs"}, {5,5,5,"Hands"} }
T["68:1"] = { {0,14,1,"Skin Color"}, {1,10,1,"Face"}, {2,11,1,"Hair Style"}, {3,14,1,"Hair Color"}, {4,11,1,"Beard Style"}, {0,14,14,"Gem Color"}, {3,14,14,"Eye Color"}, {1,4,10,"Eyesight"}, {1,2,40,"Eyebrows"}, {5,2,16,"Belt"}, {2,5,11,"Right Shoulder"}, {4,5,11,"Left Shoulder"}, {2,3,55,"Torso"}, {5,4,1,"Arms"}, {4,3,55,"Legs"}, {5,4,4,"Hands"} }
T["69:1"] = { {0,14,1,"Skin Color"}, {1,10,1,"Face"}, {2,11,1,"Hair Style"}, {3,14,1,"Hair Color"}, {4,11,1,"Beard Style"}, {0,14,14,"Gem Color"}, {3,14,14,"Eye Color"}, {1,4,10,"Eyesight"}, {1,2,40,"Eyebrows"}, {5,2,16,"Belt"}, {2,5,11,"Right Shoulder"}, {4,5,11,"Left Shoulder"}, {2,3,55,"Torso"}, {5,4,1,"Arms"}, {4,3,55,"Legs"}, {5,4,4,"Hands"} }
T["70:0"] = { {2,18,1,"Hair Style"}, {2,14,18,"Eyebrows"}, {7,4,54,"Tusk"}, {5,13,18,"Shoulder Spine"}, {0,20,1,"Skin Color"}, {1,8,1,"Face"}, {3,30,1,"Hair Color"}, {8,5,1,"Face Fur Pattern"}, {4,18,8,"Fur Color"}, {5,18,1,"Shoulder Spine Color"}, {1,23,8,"Hair Highlight Color"}, {6,10,18,"Ears"}, {0,12,20,"Eye Color"}, {8,2,125,"Nose"}, {8,5,5,"Earrings"}, {10,4,5,"Eyesight"}, {9,2,125,"Feet"}, {8,5,25,"Loincloth Color"}, {9,5,1,"Jewelry Color"}, {10,2,80,"Hair Spine Style"}, {6,18,1,"Hair Spine Color"}, {4,8,1,"Beard"}, {9,5,5,"Necklace"}, {7,9,1,"Sideburns"}, {3,6,30,"Moustache"}, {9,5,25,"Body Fur Pattern"}, {7,6,9,"Face Paint"}, {10,4,20,"Body Paint"}, {10,5,1,"Paint Color"} }
T["71:0"] = { {2,18,1,"Hair Style"}, {2,14,18,"Eyebrows"}, {7,4,54,"Tusk"}, {5,13,18,"Shoulder Spine"}, {0,20,1,"Skin Color"}, {1,8,1,"Face"}, {3,30,1,"Hair Color"}, {8,5,1,"Face Fur Pattern"}, {4,18,8,"Fur Color"}, {5,18,1,"Shoulder Spine Color"}, {1,23,8,"Hair Highlight Color"}, {6,10,18,"Ears"}, {0,12,20,"Eye Color"}, {8,2,125,"Nose"}, {8,5,5,"Earrings"}, {10,4,5,"Eyesight"}, {9,2,125,"Feet"}, {8,5,25,"Loincloth Color"}, {9,5,1,"Jewelry Color"}, {10,2,80,"Hair Spine Style"}, {6,18,1,"Hair Spine Color"}, {4,8,1,"Beard"}, {9,5,5,"Necklace"}, {7,9,1,"Sideburns"}, {3,6,30,"Moustache"}, {9,5,25,"Body Fur Pattern"}, {7,6,9,"Face Paint"}, {10,4,20,"Body Paint"}, {10,5,1,"Paint Color"} }
T["70:1"] = { {2,18,1,"Hair Style"}, {5,10,18,"Ears"}, {8,2,125,"Nose"}, {4,14,1,"Eyebrows"}, {9,4,5,"Tusk"}, {2,13,18,"Shoulder Spine"}, {7,5,6,"Body Fur Pattern"}, {3,6,30,"Face Fur Pattern"}, {0,12,20,"Eye Color"}, {1,9,1,"Face"}, {3,30,1,"Hair Color"}, {0,20,1,"Skin Color"}, {1,23,9,"Hair Highlight Color"}, {7,5,30,"Jewelry"}, {4,18,14,"Shoulder Spine Color"}, {9,4,20,"Eyesight"}, {9,2,80,"Feet"}, {10,2,4,"Hair Spine Style"}, {5,18,1,"Hair Spine Color"}, {6,9,18,"Eyelashes"}, {6,18,1,"Fur Color"}, {10,2,8,"Underclothes Top"}, {8,5,1,"Underclothes Color"}, {8,5,5,"Necklace"}, {8,5,25,"Earrings"}, {7,6,1,"Face Paint"}, {10,4,1,"Body Paint"}, {9,5,1,"Paint Color"} }
T["71:1"] = { {2,18,1,"Hair Style"}, {5,10,18,"Ears"}, {8,2,125,"Nose"}, {4,14,1,"Eyebrows"}, {9,4,5,"Tusk"}, {2,13,18,"Shoulder Spine"}, {7,5,6,"Body Fur Pattern"}, {3,6,30,"Face Fur Pattern"}, {0,12,20,"Eye Color"}, {1,9,1,"Face"}, {3,30,1,"Hair Color"}, {0,20,1,"Skin Color"}, {1,23,9,"Hair Highlight Color"}, {7,5,30,"Jewelry"}, {4,18,14,"Shoulder Spine Color"}, {9,4,20,"Eyesight"}, {9,2,80,"Feet"}, {10,2,4,"Hair Spine Style"}, {5,18,1,"Hair Spine Color"}, {6,9,18,"Eyelashes"}, {6,18,1,"Fur Color"}, {10,2,8,"Underclothes Top"}, {8,5,1,"Underclothes Color"}, {8,5,5,"Necklace"}, {8,5,25,"Earrings"}, {7,6,1,"Face Paint"}, {10,4,1,"Body Paint"}, {9,5,1,"Paint Color"} }
T["74:0"] = { {1,6,1,"Face"}, {0,8,1,"Fur Color"}, {4,1,1,"Hair Style"}, {2,6,1,"Ears"}, {1,6,6,"Snout"}, {3,33,1,"Eye Color"}, {3,2,33,"Earrings"}, {0,3,8,"Pattern"}, {2,4,6,"Eyesight"}, {4,3,1,"Eye Style"} }
T["74:1"] = { {1,6,1,"Face"}, {0,8,1,"Fur Color"}, {4,1,1,"Hair Style"}, {2,8,1,"Ears"}, {0,3,8,"Pattern"}, {1,6,6,"Snout"}, {3,33,1,"Eye Color"}, {3,2,33,"Earrings"}, {2,4,8,"Eyesight"}, {4,3,1,"Eye Style"} }
T["75:0"] = { {0,16,1,"Skin Color"}, {1,4,1,"Head Style"}, {2,8,1,"Facial Hair"} }
T["75:1"] = { {0,16,1,"Skin Color"}, {1,8,1,"Head Style"} }
T["102:0"] = { {0,16,1,"Skin Color"}, {1,4,1,"Head Style"}, {2,8,1,"Facial Hair"} }
T["102:1"] = { {0,16,1,"Skin Color"}, {1,8,1,"Head Style"} }
T["112:0"] = { {0,18,1,"Fur Color"}, {1,11,1,"Face Marking"} }
T["110:0"] = { {0,8,1,"Fur Color"}, {1,3,1,"Horn Style"}, {2,4,1,"Hair Style"} }
T["106:0"] = { {0,8,1,"Carapace Color"}, {1,6,1,"Antennae"} }
T["109:0"] = { {0,8,1,"Skin Color"} }
T["90:0"] = { {0,6,1,"Skin Color"}, {1,8,1,"Hair Color"} }
T["87:0"] = { {0,9,1,"Skin Color"} }
T["88:0"] = { {0,7,1,"Skin Color"} }
T["88:1"] = { {0,8,1,"Skin Color"} }
T["104:0"] = { {0,35,1,"Slime Color"} }
T["101:0"] = { {0,7,1,"Skin / Body Palette"}, {2,8,1,"Accessory Palette"}, {3,7,1,"Hair Color"}, {4,8,1,"Hair Style"}, {4,4,8,"Facial Hair"} }
T["101:1"] = { {0,6,1,"Skin / Body Palette"}, {2,6,1,"Accessory Palette"}, {3,6,1,"Hair Color"}, {4,8,1,"Hair Style"}, {4,5,8,"Earrings"} }
T["107:0"] = { {0,3,1,"Body Palette"}, {2,3,1,"Armor Palette"}, {3,4,1,"Wing Palette"}, {3,3,4,"Hair Palette"}, {1,3,1,"Hair Style"} }
T["107:1"] = { {0,2,1,"Body Palette"}, {2,2,1,"Armor Palette"}, {3,4,1,"Wing Palette"}, {3,2,4,"Hair Palette"}, {1,4,1,"Hair Style"} }
T["83:0"] = { {0,10,1,"Fur Color"}, {1,6,1,"Mane"}, {1,3,6,"Beard"}, {1,3,18,"Ears"}, {0,3,10,"Eyes"}, {2,3,1,"Outfit Color"}, {2,4,3,"Chest Sling"}, {2,5,12,"Cuffs"}, {3,2,1,"Waist"}, {3,2,2,"Loincloth"}, {0,4,30,"Tail"}, {3,2,4,"Leg Wraps"}, {3,3,8,"Pauldrons"}, {3,2,24,"Belt Strap"}, {4,3,1,"Trousers"} }
T["21:0"] = { {0,25,1,"Skin"}, {2,5,1,"Hair style"}, {3,15,1,"Hair color"}, {4,96,1,"Facial hair"} }
T["21:1"] = { {0,255,1,"Skin"}, {2,5,1,"Hair style"}, {3,80,1,"Hair color"}, {4,240,1,"Facial hair"} }
T["82:0"] = { {0,5,1,"Skin"}, {2,4,1,"Hair style"}, {3,4,1,"Hair color"} }
T["82:1"] = {  }
T["97:0"] = { {0,4,1,"Skin"}, {3,3,1,"Hair color"} }
T["99:0"] = { {0,7,1,"Skin"}, {2,5,1,"Hair style"}, {3,7,1,"Hair color"} }
T["99:1"] = { {0,16,1,"Skin"}, {3,25,1,"Hair color"} }
T["98:0"] = { {0,17,1,"Skin"}, {1,4,1,"Face"}, {2,6,1,"Hair style"}, {3,76,1,"Hair color"} }
T["100:0"] = { {0,17,1,"Skin"}, {1,4,1,"Face"}, {2,6,1,"Hair style"}, {3,76,1,"Hair color"} }

-- 外观选项名称的中文对照表（数据表中保留英文键，界面上显示中文）
local ZH = {
    ["Face"] = "面部", ["Skin Color"] = "肤色", ["Horn Style"] = "犄角样式", ["Horn Markings"] = "犄角纹路",
    ["Beard"] = "胡须", ["Hair"] = "发型", ["Eye Color"] = "眼睛颜色", ["Body Paint"] = "身体彩绘",
    ["Body Paint Color"] = "彩绘颜色", ["Foremane"] = "前鬃", ["Nose Piercing"] = "鼻环", ["Headdress"] = "头饰",
    ["Horn Wraps"] = "犄角缠带", ["Horn Decoration"] = "犄角装饰", ["Tail Decoration"] = "尾巴装饰", ["Tail"] = "尾巴",
    ["Jewelry Color"] = "首饰颜色", ["Feather"] = "羽毛", ["Horn Color"] = "犄角颜色", ["Eyesight"] = "瞳色",
    ["Eye Style"] = "眼睛样式", ["Hair Style"] = "发型", ["Hair Color"] = "发色", ["Beard Style"] = "胡须样式",
    ["Gem Color"] = "宝石颜色", ["Eyebrows"] = "眉毛", ["Belt"] = "腰带", ["Right Shoulder"] = "右肩",
    ["Left Shoulder"] = "左肩", ["Torso"] = "躯干", ["Arms"] = "手臂", ["Legs"] = "腿部", ["Hands"] = "手部",
    ["Tusk"] = "獠牙", ["Shoulder Spine"] = "肩部骨刺", ["Shoulder Spine Color"] = "肩部骨刺颜色",
    ["Hair Highlight Color"] = "发丝高光颜色", ["Ears"] = "耳朵", ["Nose"] = "鼻子", ["Earrings"] = "耳环",
    ["Feet"] = "脚部", ["Loincloth Color"] = "腰布颜色", ["Hair Spine Style"] = "背鬃样式",
    ["Hair Spine Color"] = "背鬃颜色", ["Sideburns"] = "鬓角", ["Moustache"] = "八字胡",
    ["Body Fur Pattern"] = "身体毛纹", ["Face Paint"] = "面部彩绘", ["Paint Color"] = "彩绘颜色",
    ["Face Fur Pattern"] = "面部毛纹", ["Eyelashes"] = "睫毛", ["Fur Color"] = "毛色",
    ["Underclothes Top"] = "内衬上衣", ["Underclothes Color"] = "内衬颜色", ["Necklace"] = "项链",
    ["Jewelry"] = "首饰", ["Snout"] = "口鼻", ["Pattern"] = "花纹", ["Head Style"] = "头部样式",
    ["Facial Hair"] = "胡须", ["Face Marking"] = "面部纹路", ["Carapace Color"] = "甲壳颜色",
    ["Antennae"] = "触角", ["Slime Color"] = "黏液颜色", ["Skin / Body Palette"] = "皮肤 / 身体配色",
    ["Accessory Palette"] = "配饰配色", ["Hair Palette"] = "发色配色", ["Body Palette"] = "身体配色",
    ["Armor Palette"] = "护甲配色", ["Wing Palette"] = "翅膀配色", ["Mane"] = "鬃毛", ["Eyes"] = "眼睛",
    ["Outfit Color"] = "服装颜色", ["Chest Sling"] = "胸带", ["Cuffs"] = "护腕", ["Waist"] = "腰部",
    ["Loincloth"] = "腰布", ["Leg Wraps"] = "绑腿", ["Pauldrons"] = "肩甲", ["Belt Strap"] = "腰带扣",
    ["Trousers"] = "长裤", ["Skin"] = "皮肤", ["Hair style"] = "发型", ["Hair color"] = "发色",
    ["Facial hair"] = "胡须",
}

local function Opts(race, gender) return T[race .. ":" .. gender] end
DevMenuLookAdapters = DevMenuLookAdapters or {}
table.insert(DevMenuLookAdapters, 1, {
    name = "CoA 种族",
    -- only claims the races it knows; every other race keeps the 5 stock rows
    Handles = function(race, gender) return Opts(race, gender) ~= nil end,
    GetOptions = function(race, gender)
        local t, out = Opts(race, gender), {}
        for i, o in ipairs(t or {}) do out[i] = { key = "o" .. i, label = ZH[o[4]] or o[4], max = o[2] } end
        return out
    end,
    -- choices -> 5 bytes + extra (fields 6..13 as one number, below 2^53)
    Encode = function(race, gender, values)
        local f = {}
        for i = 0, 12 do f[i] = 0 end
        for i, o in ipairs(Opts(race, gender) or {}) do f[o[1]] = f[o[1]] + ((values["o" .. i] or 0) % o[2]) * o[3] end
        local extra = 0
        for i = 12, 5, -1 do extra = extra * 256 + (f[i] % 256) end
        return { f[0] % 256, f[1] % 256, f[2] % 256, f[3] % 256, f[4] % 256 }, extra
    end,
    Decode = function(race, gender, bytes, extra)
        local f = { [0] = bytes[1], bytes[2], bytes[3], bytes[4], bytes[5] }
        extra = extra or 0
        for i = 5, 12 do f[i] = extra % 256; extra = math.floor(extra / 256) end
        local values = {}
        for i, o in ipairs(Opts(race, gender) or {}) do values["o" .. i] = math.floor((f[o[1]] or 0) / o[3]) % o[2] end
        return values
    end,
})
