#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    Docker 清理脚本${NC}"
echo -e "${BLUE}==========================================${NC}"
echo "此脚本将清理Docker中的悬空镜像、未使用的容器、网络和卷"
echo ""

# 检查Docker环境
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装，请先安装Docker${NC}"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        echo -e "${RED}错误: Docker服务未运行，请启动Docker服务${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Docker环境检查通过${NC}"
    echo ""
}

# 显示当前Docker资源使用情况
show_current_status() {
    echo -e "${CYAN}当前Docker资源使用情况:${NC}"
    echo "----------------------------------------"
    
    # 镜像数量
    local image_count=$(docker images -q | wc -l)
    echo "镜像数量: $image_count"
    
    # 悬空镜像数量
    local dangling_images=$(docker images -f "dangling=true" -q | wc -l)
    echo "悬空镜像数量: $dangling_images"
    
    # 容器数量
    local container_count=$(docker ps -aq | wc -l)
    echo "容器数量: $container_count"
    
    # 停止的容器数量
    local stopped_containers=$(docker ps -f "status=exited" -q | wc -l)
    echo "停止的容器数量: $stopped_containers"
    
    # 网络数量
    local network_count=$(docker network ls -q | wc -l)
    echo "网络数量: $network_count"
    
    # 卷数量
    local volume_count=$(docker volume ls -q | wc -l)
    echo "卷数量: $volume_count"
    
    # 磁盘使用情况
    local disk_usage=$(docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}")
    echo ""
    echo "磁盘使用情况:"
    echo "$disk_usage"
    
    echo ""
}

# 清理悬空镜像
clean_dangling_images() {
    echo -e "${YELLOW}正在清理悬空镜像...${NC}"
    
    local dangling_images=$(docker images -f "dangling=true" -q)
    if [ -z "$dangling_images" ]; then
        echo -e "${GREEN}✅ 没有悬空镜像需要清理${NC}"
        return
    fi
    
    local count=$(echo "$dangling_images" | wc -l)
    echo "发现 $count 个悬空镜像"
    
    if docker rmi $dangling_images 2>/dev/null; then
        echo -e "${GREEN}✅ 悬空镜像清理成功${NC}"
    else
        echo -e "${RED}❌ 部分悬空镜像清理失败（可能正在被使用）${NC}"
    fi
    
    echo ""
}

# 清理未使用的镜像
clean_unused_images() {
    echo -e "${YELLOW}正在清理未使用的镜像...${NC}"
    
    local unused_images=$(docker images -q)
    if [ -z "$unused_images" ]; then
        echo -e "${GREEN}✅ 没有镜像需要清理${NC}"
        return
    fi
    
    echo "注意: 此操作将删除所有未使用的镜像，包括有标签的镜像"
    echo "建议先检查是否有重要镜像需要保留"
    echo ""
    
    read -p "是否继续清理所有未使用的镜像? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⚠️  跳过镜像清理${NC}"
        echo ""
        return
    fi
    
    if docker image prune -a -f; then
        echo -e "${GREEN}✅ 未使用镜像清理成功${NC}"
    else
        echo -e "${RED}❌ 镜像清理失败${NC}"
    fi
    
    echo ""
}

# 清理停止的容器
clean_stopped_containers() {
    echo -e "${YELLOW}正在清理停止的容器...${NC}"
    
    local stopped_containers=$(docker ps -f "status=exited" -q)
    if [ -z "$stopped_containers" ]; then
        echo -e "${GREEN}✅ 没有停止的容器需要清理${NC}"
        return
    fi
    
    local count=$(echo "$stopped_containers" | wc -l)
    echo "发现 $count 个停止的容器"
    
    if docker container prune -f; then
        echo -e "${GREEN}✅ 停止的容器清理成功${NC}"
    else
        echo -e "${RED}❌ 容器清理失败${NC}"
    fi
    
    echo ""
}

# 清理未使用的网络
clean_unused_networks() {
    echo -e "${YELLOW}正在清理未使用的网络...${NC}"
    
    if docker network prune -f; then
        echo -e "${GREEN}✅ 未使用的网络清理成功${NC}"
    else
        echo -e "${RED}❌ 网络清理失败${NC}"
    fi
    
    echo ""
}

# 清理未使用的卷
clean_unused_volumes() {
    echo -e "${YELLOW}正在清理未使用的卷...${NC}"
    
    echo "注意: 此操作将删除所有未使用的卷，包括数据卷"
    echo "请确保没有重要数据需要保留"
    echo ""
    
    read -p "是否继续清理未使用的卷? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⚠️  跳过卷清理${NC}"
        echo ""
        return
    fi
    
    if docker volume prune -f; then
        echo -e "${GREEN}✅ 未使用的卷清理成功${NC}"
    else
        echo -e "${RED}❌ 卷清理失败${NC}"
    fi
    
    echo ""
}

# 清理构建缓存
clean_build_cache() {
    echo -e "${YELLOW}正在清理构建缓存...${NC}"
    
    if docker builder prune -f; then
        echo -e "${GREEN}✅ 构建缓存清理成功${NC}"
    else
        echo -e "${RED}❌ 构建缓存清理失败${NC}"
    fi
    
    echo ""
}

# 一键清理所有
clean_all() {
    echo -e "${PURPLE}正在执行一键清理...${NC}"
    echo "此操作将清理所有未使用的Docker资源"
    echo ""
    
    read -p "是否继续执行一键清理? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⚠️  取消一键清理${NC}"
        echo ""
        return
    fi
    
    echo "正在清理..."
    if docker system prune -a -f --volumes; then
        echo -e "${GREEN}✅ 一键清理完成${NC}"
    else
        echo -e "${RED}❌ 一键清理失败${NC}"
    fi
    
    echo ""
}

# 显示清理后的状态
show_cleanup_result() {
    echo -e "${CYAN}清理后的Docker资源使用情况:${NC}"
    echo "----------------------------------------"
    
    # 镜像数量
    local image_count=$(docker images -q | wc -l)
    echo "镜像数量: $image_count"
    
    # 悬空镜像数量
    local dangling_images=$(docker images -f "dangling=true" -q | wc -l)
    echo "悬空镜像数量: $dangling_images"
    
    # 容器数量
    local container_count=$(docker ps -aq | wc -l)
    echo "容器数量: $container_count"
    
    # 停止的容器数量
    local stopped_containers=$(docker ps -f "status=exited" -q | wc -l)
    echo "停止的容器数量: $stopped_containers"
    
    # 网络数量
    local network_count=$(docker network ls -q | wc -l)
    echo "网络数量: $network_count"
    
    # 卷数量
    local volume_count=$(docker volume ls -q | wc -l)
    echo "卷数量: $volume_count"
    
    # 磁盘使用情况
    echo ""
    echo "磁盘使用情况:"
    docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}"
    
    echo ""
}

# 显示菜单
show_menu() {
    echo -e "${BLUE}请选择要执行的清理操作:${NC}"
    echo "1. 清理悬空镜像"
    echo "2. 清理未使用的镜像"
    echo "3. 清理停止的容器"
    echo "4. 清理未使用的网络"
    echo "5. 清理未使用的卷"
    echo "6. 清理构建缓存"
    echo "7. 一键清理所有"
    echo "8. 退出"
    echo ""
}

# 主函数
main() {
    check_docker
    
    while true; do
        show_current_status
        show_menu
        
        read -p "请输入选项 (1-8): " choice
        echo ""
        
        case $choice in
            1)
                clean_dangling_images
                ;;
            2)
                clean_unused_images
                ;;
            3)
                clean_stopped_containers
                ;;
            4)
                clean_unused_networks
                ;;
            5)
                clean_unused_volumes
                ;;
            6)
                clean_build_cache
                ;;
            7)
                clean_all
                ;;
            8)
                echo -e "${GREEN}感谢使用Docker清理脚本！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选项，请重新选择${NC}"
                echo ""
                ;;
        esac
        
        # 询问是否继续
        read -p "是否继续清理其他项目? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            break
        fi
        echo ""
    done
    
    # 显示最终结果
    show_cleanup_result
    
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}    清理完成！${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo "建议定期运行此脚本以保持Docker环境整洁"
    echo "如需更多帮助，请运行: docker system df"
}

# 执行主函数
main
