package com.example.api.config;

import com.example.api.entity.User;
import com.example.api.repository.UserRepository;
import com.example.api.util.PasswordHashUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.security.config.http.SessionCreationPolicy;

import java.util.Arrays;
import java.util.Collections;

/**
 * Spring Security配置类
 * 20241219 - 创建安全配置
 * 20241219 - 修复兼容Spring Boot 2.x和JDK 1.8
 * 20250422 - 修复循环依赖问题
 * 20250422 - 修复安全配置，允许健康检查和错误页面访问
 * 20250422 - 临时使用明文密码编码器进行测试
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private UserRepository userRepository;

    /**
     * 密码编码器 - 临时使用明文编码器进行测试
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new PasswordEncoder() {
            @Override
            public String encode(CharSequence rawPassword) {
                return rawPassword.toString(); // 直接返回明文
            }
            
            @Override
            public boolean matches(CharSequence rawPassword, String encodedPassword) {
                return rawPassword.toString().equals(encodedPassword); // 直接比较明文
            }
        };
    }

    /**
     * 用户详情服务
     */
    @Bean
    public UserDetailsService userDetailsService() {
        return new UserDetailsService() {
            @Override
            public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
                return userRepository.findByUsernameAndEnabledTrue(username)
                        .map(user -> new org.springframework.security.core.userdetails.User(
                                user.getUsername(),
                                user.getPassword(),
                                user.getEnabled(),
                                true, true, true,
                                Collections.singletonList(new SimpleGrantedAuthority("USER"))
                        ))
                        .orElseThrow(() -> new UsernameNotFoundException("用户不存在: " + username));
            }
        };
    }

    /**
     * 安全配置
     * 完全禁用认证，所有接口都可以访问
     */
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .cors().and()
            .csrf().disable()
            .authorizeRequests()
                // 所有接口都允许访问，完全禁用认证
                .anyRequest().permitAll()
            .and()
            .httpBasic().disable()  // 禁用HTTP Basic认证
            .formLogin().disable()   // 禁用表单登录
            .logout().disable()      // 禁用登出
            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS);
    }

    /**
     * CORS配置
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    /**
     * 认证管理器配置
     */
    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userDetailsService()).passwordEncoder(passwordEncoder());
    }
}
