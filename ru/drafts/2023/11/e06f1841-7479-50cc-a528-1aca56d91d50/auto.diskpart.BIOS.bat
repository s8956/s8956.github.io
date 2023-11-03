:: Disk Partitions (BIOS).

echo SELECT DISK=0 >> "X:\auto.diskpart.txt"
echo CLEAN >> "X:\auto.diskpart.txt"
echo CREATE PARTITION PRIMARY SIZE=2048 >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="SYSTEM RESERVED" >> "X:\auto.diskpart.txt"
echo ACTIVE >> "X:\auto.diskpart.txt"
echo CREATE PARTITION PRIMARY >> "X:\auto.diskpart.txt"
echo SHRINK MINIMUM=4096 >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="OS" >> "X:\auto.diskpart.txt"
echo CREATE PARTITION PRIMARY >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="WINRE" >> "X:\auto.diskpart.txt"
echo SET ID=27 >> "X:\auto.diskpart.txt"
diskpart /s "X:\auto.diskpart.txt" >> "X:\auto.diskpart.log"

exit
