#!/bin/bash

echo "测试明文密码登录功能..."
echo

echo "1. 测试admin用户登录"
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'

echo
echo
echo "2. 测试user1用户登录"
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"password123"}'

echo
echo
echo "3. 测试user2用户登录"
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"password123"}'

echo
echo
echo "4. 测试错误密码"
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"wrongpassword"}'

echo
echo
echo "5. 测试不存在的用户"
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nonexistent","password":"password123"}'

echo
echo "测试完成！"
