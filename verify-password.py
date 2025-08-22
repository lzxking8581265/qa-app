#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
密码哈希验证脚本
用于验证BCrypt密码哈希是否正确
"""

import bcrypt

def verify_password():
    """验证密码哈希"""
    # 新的密码哈希
    new_hash = b"$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa"
    
    # 测试密码
    admin_password = b"admin"
    
    print("=== 密码哈希验证 ===")
    print(f"密码哈希: {new_hash.decode()}")
    print(f"测试密码: {admin_password.decode()}")
    
    # 验证密码
    try:
        is_valid = bcrypt.checkpw(admin_password, new_hash)
        print(f"验证结果: {is_valid}")
        
        if is_valid:
            print("✅ 密码哈希验证成功！")
        else:
            print("❌ 密码哈希验证失败！")
            
    except Exception as e:
        print(f"❌ 验证过程中出现错误: {e}")
    
    # 生成新的哈希进行对比
    print("\n=== 生成新哈希 ===")
    try:
        new_generated_hash = bcrypt.hashpw(admin_password, bcrypt.gensalt())
        print(f"新生成的哈希: {new_generated_hash.decode()}")
        
        # 验证新生成的哈希
        new_is_valid = bcrypt.checkpw(admin_password, new_generated_hash)
        print(f"新哈希验证结果: {new_is_valid}")
        
    except Exception as e:
        print(f"❌ 生成哈希时出现错误: {e}")

if __name__ == "__main__":
    verify_password()
