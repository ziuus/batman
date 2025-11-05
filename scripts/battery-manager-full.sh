#!/usr/bin/env bash

# Battery Management and Conservation Mode Manager (full interactive script)
# Copied from local implementation to improve transparency in the repo.

# Allow overriding paths via environment for portability/testing
CONSERVATION_MODE="${CONSERVATION_MODE:-/sys/devices/pci0000:00/0000:00:1f.0/PNP0C09:00/VPC2004:00/conservation_mode}"
BATTERY_CAPACITY="${BATTERY_CAPACITY:-/sys/class/power_supply/BAT0/capacity}"
BATTERY_STATUS="${BATTERY_STATUS:-/sys/class/power_supply/BAT0/status}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if file exists and is accessible
check_file() {
    local file=$1
    if [ ! -e "$file" ]; then
        print_status $RED "❌ File not found: $file"
        return 1
    fi
    return 0
}

# Function to display battery information
show_battery_info() {
    print_status $BLUE "\n=== BATTERY INFORMATION ==="

    if check_file "$BATTERY_CAPACITY"; then
        local capacity=$(cat "$BATTERY_CAPACITY" 2>/dev/null)
        if [ -n "$capacity" ]; then
            print_status $GREEN "🔋 Battery Capacity: ${capacity}%"
        else
            print_status $RED "❌ Unable to read battery capacity"
        fi
    fi

    if check_file "$BATTERY_STATUS"; then
        local status=$(cat "$BATTERY_STATUS" 2>/dev/null)
        if [ -n "$status" ]; then
            case $status in
                "Charging")
                    print_status $GREEN "⚡ Battery Status: $status"
                    ;;
                "Discharging")
                    print_status $YELLOW "🔻 Battery Status: $status"
                    ;;
                "Full")
                    print_status $GREEN "✅ Battery Status: $status"
                    ;;
                *)
                    print_status $BLUE "ℹ️  Battery Status: $status"
                    ;;
            esac
        else
            print_status $RED "❌ Unable to read battery status"
        fi
    fi
}

# Function to show conservation mode status
show_conservation_status() {
    print_status $BLUE "\n=== CONSERVATION MODE STATUS ==="

    if check_file "$CONSERVATION_MODE"; then
        if [ -r "$CONSERVATION_MODE" ]; then
            local mode=$(cat "$CONSERVATION_MODE" 2>/dev/null)
            case $mode in
                "1")
                    print_status $GREEN "🛡️  Conservation Mode: ENABLED (Battery limited to ~60%)"
                    ;;
                "0")
                    print_status $YELLOW "🔓 Conservation Mode: DISABLED (Full charging allowed)"
                    ;;
                *)
                    print_status $BLUE "ℹ️  Conservation Mode: Unknown status ($mode)"
                    ;;
            esac
        else
            print_status $RED "❌ Cannot read conservation mode (permission denied)"
        fi
    fi
}

# Function to toggle conservation mode
toggle_conservation_mode() {
    if ! check_file "$CONSERVATION_MODE"; then
        return 1
    fi

    if [ ! -w "$CONSERVATION_MODE" ]; then
        print_status $RED "❌ Cannot write to conservation mode file (need sudo privileges)"
        print_status $YELLOW "💡 Try running: sudo $0"
        return 1
    fi

    local current_mode=$(cat "$CONSERVATION_MODE" 2>/dev/null)

    case $current_mode in
        "0")
            echo "1" > "$CONSERVATION_MODE"
            print_status $GREEN "✅ Conservation mode ENABLED"
            ;;
        "1")
            echo "0" > "$CONSERVATION_MODE"
            print_status $GREEN "✅ Conservation mode DISABLED"
            ;;
        *)
            print_status $RED "❌ Unknown conservation mode state: $current_mode"
            return 1
            ;;
    esac
}

# Function to set conservation mode to specific value
set_conservation_mode() {
    local mode=$1

    if ! check_file "$CONSERVATION_MODE"; then
        return 1
    fi

    if [ ! -w "$CONSERVATION_MODE" ]; then
        print_status $RED "❌ Cannot write to conservation mode file (need sudo privileges)"
        print_status $YELLOW "💡 Try running: sudo $0"
        return 1
    fi

    case $mode in
        "on"|"enable"|"1")
            echo "1" > "$CONSERVATION_MODE"
            print_status $GREEN "✅ Conservation mode ENABLED"
            ;;
        "off"|"disable"|"0")
            echo "0" > "$CONSERVATION_MODE"
            print_status $GREEN "✅ Conservation mode DISABLED"
            ;;
        *)
            print_status $RED "❌ Invalid mode. Use: on/off, enable/disable, or 1/0"
            return 1
            ;;
    esac
}

# Function to display help
show_help() {
    print_status $BLUE "\n=== BATTERY MANAGER HELP ==="
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  status, -s          Show battery and conservation mode status"
    echo "  toggle, -t          Toggle conservation mode on/off"
    echo "  enable, on          Enable conservation mode"
    echo "  disable, off        Disable conservation mode"
    echo "  interactive, -i     Interactive mode (default)"
    echo "  help, -h            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 status           # Show current status"
    echo "  sudo $0 enable      # Enable conservation mode"
    echo "  sudo $0 toggle      # Toggle conservation mode"
    echo ""
    print_status $YELLOW "⚠️  Note: Changing conservation mode requires sudo privileges"
}

# Interactive menu
interactive_mode() {
    while true; do
        print_status $BLUE "\n=== BATTERY MANAGEMENT MENU ==="
        echo "1) Show Battery Status"
        echo "2) Show Conservation Mode Status"
        echo "3) Toggle Conservation Mode"
        echo "4) Enable Conservation Mode"
        echo "5) Disable Conservation Mode"
        echo "6) Show All Information"
        echo "7) Help"
        echo "0) Exit"
        echo ""
        read -p "Choose an option [0-7]: " choice

        case $choice in
            1)
                show_battery_info
                ;;
            2)
                show_conservation_status
                ;;
            3)
                toggle_conservation_mode
                ;;
            4)
                set_conservation_mode "enable"
                ;;
            5)
                set_conservation_mode "disable"
                ;;
            6)
                show_battery_info
                show_conservation_status
                ;;
            7)
                show_help
                ;;
            0)
                print_status $GREEN "👋 Goodbye!"
                exit 0
                ;;
            *)
                print_status $RED "❌ Invalid option. Please choose 0-7."
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Main script logic
case "${1:-interactive}" in
    "status"|"-s")
        show_battery_info
        show_conservation_status
        ;;
    "toggle"|"-t")
        toggle_conservation_mode
        ;;
    "enable"|"on")
        set_conservation_mode "enable"
        ;;
    "disable"|"off")
        set_conservation_mode "disable"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    "interactive"|"-i"|"")
        interactive_mode
        ;;
    *)
        print_status $RED "❌ Unknown option: $1"
        show_help
        exit 1
        ;;
esac
