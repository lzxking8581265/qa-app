package com.example.api.entity;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Email;
import javax.validation.constraints.Pattern;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户实体类
 * 20241219 - 创建用户实体
 * 20250424131103 - 扩展用户信息字段，增加手机号码、身份证、部门、性别、办公地址、血型、车牌号码、住址、座机号等
 */
@Entity
@Table(name = "users")
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "用户名不能为空")
    @Column(name = "username", nullable = false, unique = true, length = 50)
    private String username;
    
    @NotBlank(message = "密码不能为空")
    @Column(name = "password", nullable = false, length = 100)
    private String password;
    
    @Email(message = "邮箱格式不正确")
    @Column(name = "email", length = 100)
    private String email;
    
    @Column(name = "full_name", length = 100)
    private String fullName;
    
    @Column(name = "enabled", nullable = false)
    private Boolean enabled = true;
    
    // 新增字段 - 20250424131103
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号码格式不正确")
    @Column(name = "phone", length = 20)
    private String phone;
    
    @Pattern(regexp = "^[1-9]\\d{5}(18|19|20)\\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$", message = "身份证号码格式不正确")
    @Column(name = "id_card", length = 18)
    private String idCard;
    
    @Column(name = "department", length = 100)
    private String department;
    
    // 性别字段直接存储中文 - 20250424131103
    @Column(name = "gender", length = 10)
    private String gender;
    
    @Column(name = "office_address", length = 200)
    private String officeAddress;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "blood_type", length = 10)
    private BloodType bloodType;
    
    // 放宽车牌号码验证规则，允许为空或符合格式
    @Pattern(regexp = "^$|^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-Z0-9]{4}[A-Z0-9挂学警港澳]$", message = "车牌号码格式不正确")
    @Column(name = "license_plate", length = 20)
    private String licensePlate;
    
    @Column(name = "home_address", length = 200)
    private String homeAddress;
    
    // 放宽座机号码验证规则，允许为空或符合格式
    @Pattern(regexp = "^$|^0\\d{2,3}-\\d{7,8}$", message = "座机号码格式不正确")
    @Column(name = "landline", length = 20)
    private String landline;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // 20250904 - 添加关联关系，用于复杂查询
    @OneToMany(mappedBy = "userId", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<UserRole> roles;
    
    @OneToMany(mappedBy = "userId", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<UserPermission> permissions;
    
    @OneToMany(mappedBy = "userId", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<UserLoginLog> loginLogs;
    
    // 血型枚举
    public enum BloodType {
        A("A型"),
        B("B型"),
        AB("AB型"),
        O("O型");
        
        private final String displayName;
        
        BloodType(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    // 构造函数
    public User() {
        this.createdAt = LocalDateTime.now();
        this.enabled = true;
    }
    
    public User(String username, String password, String email, String fullName) {
        this();
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullName;
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
    
    // 新增字段的Getter和Setter - 20250424131103
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
    
    public BloodType getBloodType() {
        return bloodType;
    }
    
    public void setBloodType(BloodType bloodType) {
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
    
    // 20250904 - 关联关系的Getter和Setter
    public List<UserRole> getRoles() {
        return roles;
    }
    
    public void setRoles(List<UserRole> roles) {
        this.roles = roles;
    }
    
    public List<UserPermission> getPermissions() {
        return permissions;
    }
    
    public void setPermissions(List<UserPermission> permissions) {
        this.permissions = permissions;
    }
    
    public List<UserLoginLog> getLoginLogs() {
        return loginLogs;
    }
    
    public void setLoginLogs(List<UserLoginLog> loginLogs) {
        this.loginLogs = loginLogs;
    }
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    @Override
    public String toString() {
        return "User{" +
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
