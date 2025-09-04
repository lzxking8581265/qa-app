@echo off
echo 测试数据配置功能...
echo.

echo 1. 测试基础数据生成
curl -X POST http://localhost:8080/api/test-data/generate ^
  -H "Content-Type: application/json" ^
  -d "{\"customerCount\":50,\"accountsPerCustomer\":2,\"transactionsPerAccount\":5,\"riskDistribution\":\"normal\",\"includeSuspicious\":true}"

echo.
echo.
echo 2. 测试自定义风险分布
curl -X POST http://localhost:8080/api/test-data/generate ^
  -H "Content-Type: application/json" ^
  -d "{\"customerCount\":100,\"accountsPerCustomer\":3,\"transactionsPerAccount\":10,\"riskDistribution\":\"custom\",\"highRiskCount\":20,\"mediumRiskCount\":30,\"lowRiskCount\":50,\"includeSuspicious\":true}"

echo.
echo.
echo 3. 测试高风险偏重分布
curl -X POST http://localhost:8080/api/test-data/generate ^
  -H "Content-Type: application/json" ^
  -d "{\"customerCount\":200,\"accountsPerCustomer\":2,\"transactionsPerAccount\":8,\"riskDistribution\":\"high_risk\",\"includeSuspicious\":true}"

echo.
echo.
echo 4. 测试复杂配置数据生成
curl -X POST http://localhost:8080/api/test-data/generate ^
  -H "Content-Type: application/json" ^
  -d "{\"customerCount\":150,\"accountsPerCustomer\":4,\"transactionsPerAccount\":15,\"riskDistribution\":\"custom\",\"highRiskCount\":30,\"mediumRiskCount\":50,\"lowRiskCount\":70,\"includeSuspicious\":true,\"accountDistribution\":{\"savings\":50,\"checking\":30,\"credit\":15,\"loan\":5},\"transactionDistribution\":{\"deposit\":35,\"withdrawal\":25,\"transfer\":25,\"payment\":15},\"balanceRange\":{\"min\":5000,\"max\":2000000},\"transactionRange\":{\"min\":500,\"max\":100000},\"suspiciousRatio\":8,\"kycDistribution\":[\"VERIFIED\",\"PENDING\"],\"amlDistribution\":[\"CLEAR\",\"MONITORING\"],\"pepDistribution\":[\"NO\",\"YES\"]}"

echo.
echo 测试完成！
pause
