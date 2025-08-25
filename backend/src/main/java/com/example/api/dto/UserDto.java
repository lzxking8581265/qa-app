package com.example.api.dto;

import com.example.api.entity.User;
import com.fasterxml.jackson.annotation.JsonFormat;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Email;
import javax.validation.constraints.Pattern;
import java.time.LocalDateTime;

/**
 * 用户数据传输对象
 * 20250424131103 - 创建用户DTO，包含所有用户信息字段
 */
public class UserDto {
    
    private Long id;
    
    @NotBlank(message = "用户名不能为空")
    private String username;
    
    private String password; // 创建时必填，更新时可选
    
    @Email(message = "邮箱格式不正确")
    private String email;
    
    private String fullName;
    
    private Boolean enabled = true;
    
    // 新增字段 - 20250424131103
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号码格式不正确")
    private String phone;
    
    @Pattern(regexp = "^[1-9]\\d{5}(18|19|20)\\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$", message = "身份证号码格式不正确")
    private String idCard;
    
    private String department;
    
    private String gender;
    
    private String officeAddress;
    
    private User.BloodType bloodType;
    
    @Pattern(regexp = "^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-Z0-9]{4}[A-Z0-9挂学警港澳]$", message = "车牌号码格式不正确")
    private String licensePlate;
    
    private String homeAddress;
    
    @Pattern(regexp = "^0\\d{2,3}-\\d{7,8}$", message = "座机号码格式不正确")
    private String landline;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
    
    // 构造函数
    public UserDto() {}
    
    public UserDto(String username, String password, String email, String fullName) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullName;
        this.enabled = true;
    }
    
    // 从实体转换为DTO
    public static UserDto fromEntity(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setFullName(user.getFullName());
        dto.setEnabled(user.getEnabled());
        dto.setPhone(user.getPhone());
        dto.setIdCard(user.getIdCard());
        dto.setDepartment(user.getDepartment());
        dto.setGender(user.getGender());
        dto.setOfficeAddress(user.getOfficeAddress());
        dto.setBloodType(user.getBloodType());
        dto.setLicensePlate(user.getLicensePlate());
        dto.setHomeAddress(user.getHomeAddress());
        dto.setLandline(user.getLandline());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        return dto;
    }
    
    // 转换为实体（不包含密码）
    public User toEntity() {
        User user = new User();
        user.setId(this.id);
        user.setUsername(this.username);
        user.setEmail(this.email);
        user.setFullName(this.fullName);
        user.setEnabled(this.enabled);
        user.setPhone(this.phone);
        user.setIdCard(this.idCard);
        user.setDepartment(this.department);
        user.setGender(this.gender);
        user.setOfficeAddress(this.officeAddress);
        user.setBloodType(this.bloodType);
        user.setLicensePlate(this.licensePlate);
        user.setHomeAddress(this.homeAddress);
        user.setLandline(this.landline);
        return user;
    }
    
    // Getter和Setter方法
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public Boolean getEnabled() {
        return enabled;
    }
    
    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getIdCard() {
        return idCard;
    }
    
    public void setIdCard(String idCard) {
        this.idCard = idCard;
    }
    
    public String getDepartment() {
        return department;
    }
    
    public void setDepartment(String department) {
        this.department = department;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public String getOfficeAddress() {
        return officeAddress;
    }
    
    public void setOfficeAddress(String officeAddress) {
        this.officeAddress = officeAddress;
    }
    
    public User.BloodType getBloodType() {
        return bloodType;
    }
    
    public void setBloodType(User.BloodType bloodType) {
        this.bloodType = bloodType;
    }
    
    public String getLicensePlate() {
        return licensePlate;
    }
    
    public void setLicensePlate(String licensePlate) {
        this.licensePlate = licensePlate;
    }
    
    public String getHomeAddress() {
        return homeAddress;
    }
    
    public void setHomeAddress(String homeAddress) {
        this.homeAddress = homeAddress;
    }
    
    public String getLandline() {
        return landline;
    }
    
    public void setLandline(String landline) {
        this.landline = landline;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    @Override
    public String toString() {
        return "UserDto{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", phone='" + phone + '\'' +
                ", department='" + department + '\'' +
                ", gender=" + gender +
                ", officeAddress='" + officeAddress + '\'' +
                ", bloodType=" + bloodType +
                ", licensePlate='" + licensePlate + '\'' +
                ", homeAddress='" + homeAddress + '\'' +
                ", landline='" + landline + '\'' +
                ", enabled=" + enabled +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
