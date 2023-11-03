:: Disk Partitions (UEFI).

echo SELECT DISK=0 >> "X:\auto.diskpart.txt"
echo CLEAN >> "X:\auto.diskpart.txt"
echo CONVERT GPT >> "X:\auto.diskpart.txt"
echo CREATE PARTITION EFI SIZE=1024 >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=FAT32 LABEL="SYSTEM" >> "X:\auto.diskpart.txt"
echo CREATE PARTITION MSR SIZE=2048 >> "X:\auto.diskpart.txt"
echo CREATE PARTITION PRIMARY >> "X:\auto.diskpart.txt"
echo SHRINK MINIMUM=4096 >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="OS" >> "X:\auto.diskpart.txt"
echo CREATE PARTITION PRIMARY >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="WINRE" >> "X:\auto.diskpart.txt"
echo SET ID="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >> "X:\auto.diskpart.txt"
echo GPT ATTRIBUTES=0x8000000000000001 >> "X:\auto.diskpart.txt"
diskpart /s "X:\auto.diskpart.txt" >> "X:\auto.diskpart.log"

exit
