PLATFORM=`uname -m`
if [ `echo $PLATFORM | grep "sun"` ]
then
PLATFORM=sol
elif [ $PLATFORM = "i686" ]
then
PLATFORM=lin
elif [ $PLATFORM = "x86_64" ]
then
PLATFORM=lin64
else
PLATFORM=lin
fi
XILINX=/home/bogner/local/Xilinx92i
export XILINX

if [ -n "$LMC_HOME" ]
then
   LMC_HOME=${XILINX}/smartmodel/${PLATFORM}/installed_${PLATFORM}:${LMC_HOME}
else
   LMC_HOME=${XILINX}/smartmodel/${PLATFORM}/installed_${PLATFORM}
fi
export LMC_HOME

if [ -n "$PATH" ]
then
   PATH=${XILINX}/bin/${PLATFORM}:${PATH}
else
   PATH=${XILINX}/bin/${PLATFORM}
fi
export PATH

if [ -n "$LD_LIBRARY_PATH" ]
then
   LD_LIBRARY_PATH=${XILINX}/bin/${PLATFORM}:/usr/X11R6/lib:${LD_LIBRARY_PATH}
else
   LD_LIBRARY_PATH=${XILINX}/bin/${PLATFORM}:/usr/X11R6/lib
fi
export LD_LIBRARY_PATH

if [ -n "$NPX_PLUGIN_PATH" ]
then
   NPX_PLUGIN_PATH=${XILINX}/java/${PLATFORM}/jre/plugin/i386/ns4:${NPX_PLUGIN_PATH}
else
   NPX_PLUGIN_PATH=${XILINX}/java/${PLATFORM}/jre/plugin/i386/ns4
fi
export NPX_PLUGIN_PATH

qtDir=${HOME}/.qt

myxilinxrc=${qtDir}/xilinxrc

if [ -d "${SYSCONF}/xilinxrc" -a ! -f "$myxilinxrc" ]
then mkdir -p "$qtDir"
     cp "${SYSCONF}/xilinxrc" "$myxilinxrc"
elif [ -f "/Xilinx/xilinxrc" -a ! -f "$myxilinxrc" ]
then mkdir -p "$qtDir"
     cp "/Xilinx/xilinxrc" "$myxilinxrc"
fi
export PRINTER=Home
export DISPLAY=:0
exec ise
