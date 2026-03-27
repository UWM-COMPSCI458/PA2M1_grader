#!/bin/bash

TESTER=$1
SUBMISSION=$2
ASSEMBLER=$3

INST_CORRECT=0
TOTAL_CORRECT=0

function imm() {

  rnd=$RANDOM
  ty=$(( RANDOM % 2 ))
  sign=$(( RANDOM % 2 ))

  # If imm is in decimal
  if [[ $ty -eq 0 ]]; then
    # if imm is positive
    if [[ $sign -eq 0 ]]; then
      echo -n $rnd
    # if imm is negative
    else
      echo -n "-$rnd"
    fi
  # if imm is in hex
  else
    # if imm is positive
    if [[ $sign -eq 0 ]]; then
      printf "0x%x" $(( rnd & 0x7FFF ))
    # if imm is negative
    else
      printf "0x%x" $(( rnd | 0x8000 ))
    fi
  fi
}

function reg() {
  rnd=$(( RANDOM % 32 ))
  ty=$(( RANDOM % 2 ))

  if [[ $ty -eq 0 ]]; then
    case "$rnd" in
      "0")
        echo -n "\$zero"
        ;;
      "1")
        echo -n "\$at"
        ;;
      "2")
        echo -n "\$v0"
        ;;
      "3")
        echo -n "\$v1"
        ;;
      "4")
        echo -n "\$a0"
        ;;
      "5")
        echo -n "\$a1"
        ;;
      "6")
        echo -n "\$a2"
        ;;
      "7")
        echo -n "\$a3"
        ;;
      "8")
        echo -n "\$t0"
        ;;
      "9")
        echo -n "\$t1"
        ;;
      "10")
        echo -n "\$t2"
        ;;
      "11")
        echo -n "\$t3"
        ;;
      "12")
        echo -n "\$t4"
        ;;
      "13")
        echo -n "\$t5"
        ;;
      "14")
        echo -n "\$t6"
        ;;
      "15")
        echo -n "\$t7"
        ;;
      "16")
        echo -n "\$s0"
        ;;
      "17")
        echo -n "\$s1"
        ;;
      "18")
        echo -n "\$s2"
        ;;
      "19")
        echo -n "\$s3"
        ;;
      "20")
        echo -n "\$s4"
        ;;
      "21")
        echo -n "\$s5"
        ;;
      "22")
        echo -n "\$s6"
        ;;
      "23")
        echo -n "\$s7"
        ;;
      "24")
        echo -n "\$t8"
        ;;
      "25")
        echo -n "\$t9"
        ;;
      "26")
        echo -n "\$k0"
        ;;
      "27")
        echo -n "\$k1"
        ;;
      "28")
        echo -n "\$gp"
        ;;
      "29")
        echo -n "\$sp"
        ;;
      "30")
        echo -n "\$fp"
        ;;
      "31")
        echo -n "\$ra"
        ;;
      esac
    else
      echo -n "\$$rnd"
  fi

}

function rtype() {
  echo -en "$1 $(reg),$(reg),$(reg)" 
}

function itype1() {
  echo -en "$1 $(reg),$(reg),$(imm)" 
}

function itype2() {
  echo -en "$1 $(reg),$(imm)" 
}

function memtype() {
  offset=$(( RANDOM % 1024 ))
  echo -en "$1 $(reg),$offset($(reg))"
}

function generate_line() {
  case $1 in
    "add")
      line=$(rtype add)
      ;;
    "addiu")
      line=$(itype1 addiu)
      ;;
    "and")
      line=$(rtype and)
      ;;
    "andi")
      line=$(itype1 andi)
      ;;
    "beq")
      line=$(itype1 beq)
      ;;
    "bne")
      line=$(itype1 bne)
      ;;
    "j")
      line=$(echo -en "j 0x0040$(printf "%x\n" $RANDOM)")
      ;;
    "lui")
      line=$(itype2 lui)
      ;;
    "lw")
      line=$(memtype lw)
      ;;
    "or")
      line=$(rtype or)
      ;;
    "ori")
      line=$(itype1 ori)
      ;;
    "slt")
      line=$(rtype slt)
      ;;
    "sub")
      line=$(rtype sub)
      ;;
    "sw")
      line=$(memtype sw)
      ;;
    "syscall")
      line=$(echo -en "syscall")
  esac

  echo -en $line

}

function execute_test() {
  line=$(generate_line $1)
  inst=$($ASSEMBLER "$line")
  inst="${inst:2}"
  result=$($SUBMISSION "$inst")
  correct_result=$($TESTER "$inst")

  echo "Evaluating instruction: \`$inst\`"
  echo "> Assembly: $line"
  echo "> Evaluated output: $result"
  echo "> Expected output:  $correct_result"
  if [ "$result" = "$correct_result" ]; then
    ((INST_CORRECT++))
    ((TOTAL_CORRECT++))
    echo "> Output is correct (1/1) ✅"
    echo
  else
    echo "> Output is incorrect (0/1) ❌"
    echo
  fi
}

instructions=("add" "addiu" "and" "andi" "beq" "bne"
"j" "lui" "lw" "or" "ori" "slt" "sub" "sw" "syscall")



for inst in "${instructions[@]}"
do
  INST_CORRECT=0
  
  echo "## Testing instruction $inst"
  echo
  
  for ((i=0; i<5; i++))
  do
    execute_test $inst
  done

  echo
  echo "**Instruction score: $INST_CORRECT / 5**"
  echo
  echo "**********"
done

echo
echo "# Total score: $TOTAL_CORRECT / 75"

exit $TOTAL_CORRECT
