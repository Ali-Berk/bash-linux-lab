#!/bin/bash
if [[ "$1" == '' || ! "$1" =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 int:istenilen"
    exit 1
fi

istenilen=$1
banknot=(1 3 4)
adet=(0)
son_kullanilan=(0)
cevap=()
hafiza=0
for (( i=1; i<=istenilen; i++));do
    sayac=9999999
    for b in "${banknot[@]}";do
        if (( i >=  b )); then
            a=$(( i-b ))
            hafiza=$((${adet[a]}+1))
            if (( hafiza <= sayac )); then 
                sayac=$hafiza
                son_kul=$b
            fi
        fi
    done
    adet+=("$sayac")
    son_kullanilan+=("$son_kul")
done

kalan_tutar=$istenilen
while (( kalan_tutar > 0 )); do
    son=${son_kullanilan[kalan_tutar]}
    cevap+=("$son")
    kalan_tutar=$(( kalan_tutar - son ))
done
echo "Alınan: $istenilen, Bozukluk Sayısı:$hafiza ,Verilecek:,${cevap[@]}"
echo "${son_kullanilan[@]},asd ${adet[@]}"