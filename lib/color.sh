GREEN='\033[0;32m'; 
YELLOW='\033[1;33m'; 
NC='\033[0m'

say() { echo -e "${GREEN}[*]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }