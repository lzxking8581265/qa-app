package com.example.api.service;

import com.example.api.entity.User;
import com.example.api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * 测试用户生成服务
 * 20250424131103 - 创建测试用户生成服务，用于生成指定数量的测试用户数据
 */
@Service
public class TestUserGeneratorService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    private final Random random = new Random();
    
    // 部门列表
    private static final String[] DEPARTMENTS = {
        "技术部", "产品部", "运营部", "市场部", "销售部", "人事部", "财务部", "法务部", "客服部", "设计部",
        "研发部", "测试部", "运维部", "架构部", "前端部", "后端部", "移动端部", "数据部", "算法部", "安全部",
        "商务部", "渠道部", "品牌部", "公关部", "培训部", "行政部", "采购部", "物流部", "仓储部", "质量部",
        "生产部", "工程部", "设备部", "环保部", "能源部", "基建部", "物业部", "安保部", "医疗部", "教育部"
    };
    
    // 办公地址列表
    private static final String[] OFFICE_ADDRESSES = {
        "北京市朝阳区建国门外大街1号", "上海市浦东新区陆家嘴环路1000号", "广州市天河区珠江新城花城大道85号",
        "深圳市南山区深南大道10000号", "杭州市西湖区文三路259号", "成都市高新区天府大道中段1388号",
        "武汉市武昌区中南路99号", "西安市雁塔区高新四路15号", "南京市建邺区江东中路235号", "重庆市渝中区解放碑步行街",
        "北京市海淀区中关村大街27号", "上海市黄浦区南京东路123号", "广州市越秀区中山五路33号",
        "深圳市福田区深南大道2008号", "杭州市上城区解放路88号", "成都市锦江区春熙路步行街",
        "武汉市江汉区江汉路步行街", "西安市碑林区东大街", "南京市鼓楼区中山路321号", "重庆市渝中区解放碑",
        "北京市西城区西单北大街120号", "上海市静安区南京西路1266号", "广州市荔湾区上下九步行街",
        "深圳市罗湖区深南东路5002号", "杭州市滨江区江南大道588号", "成都市武侯区人民南路四段",
        "武汉市洪山区珞喻路129号", "西安市新城区东新街319号", "南京市玄武区中山路321号", "重庆市江北区观音桥步行街"
    };
    
    // 住址列表
    private static final String[] HOME_ADDRESSES = {
        "北京市海淀区中关村大街27号", "上海市黄浦区南京东路123号", "广州市越秀区中山五路33号",
        "深圳市福田区深南大道2008号", "杭州市上城区解放路88号", "成都市锦江区春熙路步行街",
        "武汉市江汉区江汉路步行街", "西安市碑林区东大街", "南京市鼓楼区中山路321号", "重庆市渝中区解放碑",
        "北京市朝阳区三里屯路19号", "上海市徐汇区淮海中路999号", "广州市海珠区江南大道中",
        "深圳市南山区科技园南区", "杭州市西湖区文三路478号", "成都市青羊区人民中路",
        "武汉市武昌区水果湖", "西安市雁塔区小寨东路", "南京市江宁区东山街道", "重庆市南岸区南坪步行街",
        "北京市丰台区方庄芳星园", "上海市长宁区虹桥路1号", "广州市白云区机场路",
        "深圳市宝安区新安街道", "杭州市江干区钱江新城", "成都市成华区建设路",
        "武汉市硚口区古田路", "西安市莲湖区西大街", "南京市浦口区江浦街道", "重庆市沙坪坝区三峡广场"
    };
    
    // 姓氏列表
    private static final String[] SURNAMES = {
        "张", "王", "李", "赵", "陈", "刘", "杨", "黄", "周", "吴", "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗",
        "梁", "宋", "郑", "谢", "韩", "唐", "冯", "于", "董", "萧", "程", "曹", "袁", "邓", "许", "傅", "沈", "曾", "彭", "吕",
        "苏", "卢", "蒋", "蔡", "贾", "丁", "魏", "薛", "叶", "阎", "余", "潘", "杜", "戴", "夏", "钟", "汪", "田", "任", "姜",
        "范", "方", "石", "姚", "谭", "廖", "邹", "熊", "金", "陆", "郝", "孔", "白", "崔", "康", "毛", "邱", "秦", "江", "史",
        "顾", "侯", "邵", "孟", "龙", "万", "段", "雷", "钱", "汤", "尹", "黎", "易", "常", "武", "乔", "贺", "赖", "龚", "文"
    };
    
    // 名字列表（单字名）
    private static final String[] GIVEN_NAMES_SINGLE = {
        "伟", "芳", "娜", "敏", "静", "丽", "强", "磊", "军", "洋", "勇", "艳", "杰", "娟", "涛", "明", "超", "霞", "平", "刚",
        "桂", "英", "华", "玉", "萍", "红", "燕", "鹏", "辉", "梅", "琳", "雪", "雷", "波", "飞", "宇", "浩", "天", "晨", "阳",
        "春", "夏", "秋", "冬", "东", "南", "西", "北", "中", "正", "大", "小", "新", "旧", "长", "短", "高", "低", "远", "近"
    };
    
    // 名字列表（双字名）
    private static final String[] GIVEN_NAMES_DOUBLE = {
        "秀英", "秀兰", "秀珍", "秀梅", "秀芳", "秀华", "秀云", "秀霞", "秀芬", "秀琴",
        "建华", "建国", "建军", "建平", "建明", "建强", "建辉", "建文", "建武", "建新",
        "志强", "志明", "志华", "志平", "志军", "志伟", "志刚", "志勇", "志远", "志高",
        "文华", "文强", "文明", "文平", "文军", "文伟", "文刚", "文勇", "文远", "文高",
        "德明", "德强", "德华", "德平", "德军", "德伟", "德刚", "德勇", "德远", "德高"
    };
    
    /**
     * 生成指定数量的测试用户
     * @param count 要生成的用户数量
     * @return 生成的用户列表
     */
    @Transactional
    public List<User> generateTestUsers(int count) {
        List<User> users = new ArrayList<>();
        
        // 生成一个随机的5位英文字符串作为批次前缀
        String batchPrefix = generateRandomEnglishPrefix();
        
        for (int i = 1; i <= count; i++) {
            User user = createRandomUser(i, batchPrefix);
            users.add(user);
        }
        
        // 批量保存用户
        userRepository.saveAll(users);
        
        return users;
    }
    
    /**
     * 生成随机5位英文字符串作为批次前缀
     * @return 5位随机英文字符串
     */
    private String generateRandomEnglishPrefix() {
        StringBuilder prefix = new StringBuilder();
        for (int i = 0; i < 5; i++) {
            // 生成随机小写字母
            char randomChar = (char) ('a' + random.nextInt(26));
            prefix.append(randomChar);
        }
        return prefix.toString();
    }
    
    /**
     * 创建随机用户
     * @param index 用户序号
     * @param batchPrefix 批次前缀
     * @return 随机用户对象
     */
    private User createRandomUser(int index, String batchPrefix) {
        User user = new User();
        
        // 生成用户名（使用批次前缀+序号，确保唯一性）
        String username = batchPrefix + index;
        user.setUsername(username);
        
        // 设置密码与用户名相同 - 20250424131103
        user.setPassword(passwordEncoder.encode(username));
        
        // 设置姓名
        user.setFullName(generateRandomName());
        
        // 设置邮箱
        user.setEmail(generateRandomEmail(username));
        
        // 设置手机号码
        user.setPhone(generateRandomPhone());
        
        // 设置身份证号码
        user.setIdCard(generateRandomIdCard());
        
        // 设置部门
        user.setDepartment(DEPARTMENTS[random.nextInt(DEPARTMENTS.length)]);
        
        // 设置性别（只使用中文"男"/"女"）
        user.setGender(random.nextBoolean() ? "男" : "女");
        
        // 设置办公地址
        user.setOfficeAddress(OFFICE_ADDRESSES[random.nextInt(OFFICE_ADDRESSES.length)]);
        
        // 设置血型
        user.setBloodType(User.BloodType.values()[random.nextInt(User.BloodType.values().length)]);
        
        // 设置车牌号码（确保所有用户都有车牌号码）
        user.setLicensePlate(generateRandomLicensePlate());
        
        // 设置住址
        user.setHomeAddress(HOME_ADDRESSES[random.nextInt(HOME_ADDRESSES.length)]);
        
        // 设置座机号（确保所有用户都有座机号）
        user.setLandline(generateRandomLandline());
        
        // 设置状态（所有测试用户都是启用状态）
        user.setEnabled(true);
        
        // 设置创建时间（最近3个月内）
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime randomTime = now.minusDays(random.nextInt(90));
        user.setCreatedAt(randomTime);
        
        return user;
    }
    
    /**
     * 生成随机姓名
     * @return 随机姓名
     */
    private String generateRandomName() {
        String surname = SURNAMES[random.nextInt(SURNAMES.length)];
        
        // 随机选择单字名或双字名
        if (random.nextBoolean()) {
            // 单字名
            String givenName = GIVEN_NAMES_SINGLE[random.nextInt(GIVEN_NAMES_SINGLE.length)];
            return surname + givenName;
        } else {
            // 双字名
            String givenName = GIVEN_NAMES_DOUBLE[random.nextInt(GIVEN_NAMES_DOUBLE.length)];
            return surname + givenName;
        }
    }
    
    /**
     * 生成随机邮箱
     * @param username 用户名
     * @return 随机邮箱
     */
    private String generateRandomEmail(String username) {
        // 用户名已经是英文+数字格式，直接使用作为邮箱前缀
        String emailPrefix = username;
        
        String[] domains = {
            "gmail.com", "qq.com", "163.com", "126.com", "sina.com", "sohu.com", "hotmail.com",
            "outlook.com", "yahoo.com", "foxmail.com", "139.com", "189.cn", "wo.cn", "21cn.com",
            "yeah.net", "netease.com", "tom.com", "263.net", "xinhuanet.com", "people.com.cn"
        };
        String domain = domains[random.nextInt(domains.length)];
        return emailPrefix + "@" + domain;
    }
    
    /**
     * 生成随机手机号码
     * @return 随机手机号码
     */
    private String generateRandomPhone() {
        String[] prefixes = {"130", "131", "132", "133", "134", "135", "136", "137", "138", "139",
                           "150", "151", "152", "153", "155", "156", "157", "158", "159",
                           "180", "181", "182", "183", "184", "185", "186", "187", "188", "189"};
        String prefix = prefixes[random.nextInt(prefixes.length)];
        String suffix = String.format("%08d", random.nextInt(100000000));
        return prefix + suffix;
    }
    
    /**
     * 生成随机身份证号码
     * @return 随机身份证号码
     */
    private String generateRandomIdCard() {
        // 生成前17位
        StringBuilder idCard = new StringBuilder();
        
        // 省份代码（前2位）
        String[] provinces = {"11", "12", "13", "14", "15", "21", "22", "23", "31", "32", "33", "34", "35", "36", "37", "41", "42", "43", "44", "45", "46", "50", "51", "52", "53", "54", "61", "62", "63", "64", "65"};
        idCard.append(provinces[random.nextInt(provinces.length)]);
        
        // 地市代码（第3-4位）
        idCard.append(String.format("%02d", random.nextInt(100)));
        
        // 区县代码（第5-6位）
        idCard.append(String.format("%02d", random.nextInt(100)));
        
        // 出生日期（第7-14位，1980-2000年，确保日期有效）
        int year = 1980 + random.nextInt(21);
        int month = 1 + random.nextInt(12);
        // 根据月份确定最大天数
        int maxDay = 31;
        if (month == 2) {
            maxDay = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) ? 29 : 28;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            maxDay = 30;
        }
        int day = 1 + random.nextInt(maxDay);
        idCard.append(String.format("%04d%02d%02d", year, month, day));
        
        // 顺序码（第15-17位）
        idCard.append(String.format("%03d", random.nextInt(1000)));
        
        // 计算校验码（第18位）
        String checkCode = calculateIdCardCheckCode(idCard.toString());
        idCard.append(checkCode);
        
        return idCard.toString();
    }
    
    /**
     * 计算身份证校验码
     * @param idCard17 前17位身份证号码
     * @return 校验码
     */
    private String calculateIdCardCheckCode(String idCard17) {
        int[] weights = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2};
        char[] checkCodes = {'1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'};
        
        int sum = 0;
        for (int i = 0; i < 17; i++) {
            sum += (idCard17.charAt(i) - '0') * weights[i];
        }
        
        int checkIndex = sum % 11;
        return String.valueOf(checkCodes[checkIndex]);
    }
    
    /**
     * 生成随机车牌号码
     * @return 随机车牌号码
     */
    private String generateRandomLicensePlate() {
        String[] provinces = {"京", "津", "沪", "渝", "冀", "豫", "云", "辽", "黑", "湘", "皖", "鲁", "新", "苏", "浙", "赣", "鄂", "桂", "甘", "晋", "蒙", "陕", "吉", "闽", "贵", "粤", "青", "藏", "川", "宁", "琼"};
        String province = provinces[random.nextInt(provinces.length)];
        
        // 生成字母和数字组合
        StringBuilder plate = new StringBuilder(province);
        plate.append((char) ('A' + random.nextInt(26)));
        
        // 生成5位字母数字组合（总共7位：省份+字母+5位字母数字）
        for (int i = 0; i < 5; i++) {
            if (random.nextBoolean()) {
                plate.append((char) ('A' + random.nextInt(26)));
            } else {
                plate.append(random.nextInt(10));
            }
        }
        
        return plate.toString();
    }
    
    /**
     * 生成随机座机号码
     * @return 随机座机号码
     */
    private String generateRandomLandline() {
        String[] areaCodes = {"010", "021", "020", "0755", "0571", "028", "027", "029", "025", "023"};
        String areaCode = areaCodes[random.nextInt(areaCodes.length)];
        String number = String.format("%07d", random.nextInt(10000000));
        return areaCode + "-" + number;
    }
    
    /**
     * 批量删除admin用户外的其他所有测试用户
     * @return 删除的用户数量
     */
    @Transactional
    public int deleteAllTestUsers() {
        List<User> testUsers = userRepository.findByUsernameNot("admin");
        int count = testUsers.size();
        userRepository.deleteAll(testUsers);
        return count;
    }
    
    /**
     * 导出所有用户信息到CSV格式
     * @return CSV内容的字节数组
     */
    public byte[] exportUsersToCsv() {
        List<User> users = userRepository.findAll();
        
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream();
             OutputStreamWriter osw = new OutputStreamWriter(baos, StandardCharsets.UTF_8);
             PrintWriter writer = new PrintWriter(osw)) {
            
            // 写入CSV头部（包含BOM以支持中文）
            writer.write('\ufeff');
            
            // CSV头部
            writer.println("用户名,密码,姓名,邮箱,手机号码,身份证号码,部门,性别,办公地址,血型,车牌号码,住址,座机号码,状态,创建时间");
            
            // 写入用户数据
            for (User user : users) {
                StringBuilder line = new StringBuilder();
                line.append(escapeCsvField(user.getUsername())).append(",");
                line.append(escapeCsvField(user.getUsername())).append(","); // 密码与用户名相同
                line.append(escapeCsvField(user.getFullName())).append(",");
                line.append(escapeCsvField(user.getEmail())).append(",");
                line.append(escapeCsvField(user.getPhone())).append(",");
                line.append(escapeCsvField(user.getIdCard())).append(",");
                line.append(escapeCsvField(user.getDepartment())).append(",");
                line.append(escapeCsvField(user.getGender())).append(",");
                line.append(escapeCsvField(user.getOfficeAddress())).append(",");
                line.append(escapeCsvField(user.getBloodType() != null ? user.getBloodType().getDisplayName() : "")).append(",");
                line.append(escapeCsvField(user.getLicensePlate())).append(",");
                line.append(escapeCsvField(user.getHomeAddress())).append(",");
                line.append(escapeCsvField(user.getLandline())).append(",");
                line.append(escapeCsvField(user.getEnabled() ? "启用" : "禁用")).append(",");
                line.append(escapeCsvField(user.getCreatedAt() != null ? 
                    user.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) : "")).append(",");
                
                writer.println(line.toString());
            }
            
            writer.flush();
            return baos.toByteArray();
            
        } catch (Exception e) {
            throw new RuntimeException("导出CSV失败", e);
        }
    }
    
    /**
     * 转义CSV字段，处理包含逗号、引号等特殊字符的情况
     * @param field 字段值
     * @return 转义后的字段值
     */
    private String escapeCsvField(String field) {
        if (field == null) {
            return "";
        }
        
        // 如果字段包含逗号、引号或换行符，需要用双引号包围
        if (field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r")) {
            // 将字段中的双引号替换为两个双引号
            String escaped = field.replace("\"", "\"\"");
            return "\"" + escaped + "\"";
        }
        
        return field;
    }
}
