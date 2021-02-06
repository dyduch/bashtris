#!/bin/sh

CURRENT_ACTION=0
ACTION_LEFT=1
ACTION_RIGHT=2
ACTION_ROTATION=3

HEIGHT=14
WIDTH=10

ARRAY=()

INITIAL_ROW=0
INITIAL_COLUMN=4
PIX_ONE=0
PIX_TWO=0
PIX_THREE=0
PIX_FOUR=0

BLOCK_TYPE=0

O_BLOCK=0
T_BLOCK=1
Z_BLOCK=2
S_BLOCK=3
I_BLOCK=4
L_BLOCK=5
J_BLOCK=6

CAN_MOVE_DOWN=1

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)

COLOR=$NORMAL

MAX_RIGHT=0
MIN_LEFT=0
MAX_DOWN=0

FIELD_EMPTY=1
FIELD_CURRENT=2

O_BLOCK=3
T_BLOCK=4
Z_BLOCK=5
S_BLOCK=6
I_BLOCK=7
L_BLOCK=8
J_BLOCK=9

CURRENT_ROTATION=0
ROTATION_UP=0
ROTATION_RIGHT=1
ROTATION_DOWN=2
ROTATION_LEFT=3

POINTS=0

prepareArray() {
    for i in $(seq 0 1 149)
    do
        ARRAY+=($FIELD_EMPTY)
    done
}

setMaxDown() {
    local max number

    max="$1"

    for number in "${@:2}"; do
        if ((number > max))
        then
        max="$number"
        fi
    done

    MAX_DOWN="$max"
}

setMaxRight() {
    local max number

    max="$1"

    for number in "${@:2}"; do
        if ((number > max))
        then
        max="$number"
        fi
    done

    MAX_RIGHT="$max"
}

setMinLeft() {
    local min number

    min="$1"

    for number in "${@:2}"; do
        if ((number < min)) 
        then
        min="$number"
        fi
    done

    MIN_LEFT="$min"
}


function printBorders() {
    for i in {0..10}
    do
        for j in {1..15}
            do
                tput cup ${j} ${i}

                if [ $i -eq 10 ]
                then
                    printf "X"
                else
                    if [ $j -eq 15 ]
                    then
                        printf "X"
                    fi
                fi
            done
            printf "\n\n"
    done
}

function printSingleField() {
    case $1 in

        $O_BLOCK)
            printf "$LIME_YELLOW"
            ;;

        $T_BLOCK)
            printf "$MAGENTA"
            ;;

        $L_BLOCK)
            printf "$BLUE"
            ;;

        $J_BLOCK)
            printf "$YELLOW"
            ;;

        $Z_BLOCK)
            printf "$RED"
            ;;

        $S_BLOCK)
            printf "$GREEN"
            ;;

        $I_BLOCK)
            printf "$CYAN"
            ;;
    esac

    printf "O"
    printf "$NORMAL"
}

function reprintBoard() {
    for i in {0..149}
    do
        local row col
        row=$(ToRow $i)
        col=$(ToCol $i)
        tput cup ${row} ${col}
        local value
        value=${ARRAY[i]}

        if [ $value -gt $FIELD_CURRENT ]
        then
            printSingleField $value
        else
            printf " "
        fi
    printf "\n\n"
    done
}

function getRandomBlock() {
    echo $((3 + $RANDOM % 7))
    
}

function selectBlockType() {
    BLOCK_TYPE=$(getRandomBlock)
}

function ToRow() {
    echo "$(($1 / $WIDTH))"
}

function ToCol() {
    echo "$(($1 % $WIDTH))"
}

function ColRowTo1D() {
    echo "$(($2*$WIDTH+$1))"
}

function resetPixels() {
    PIX_ONE=0
    PIX_TWO=0
    PIX_THREE=0
    PIX_FOUR=0
    COLOR=$NORMAL
}

function setPixels() {
    if [ $BLOCK_TYPE -eq $O_BLOCK ]
    then
        PIX_ONE=$(ColRowTo1D $INITIAL_COLUMN $INITIAL_ROW)
        PIX_TWO=$(ColRowTo1D $(($INITIAL_COLUMN + 1)) $INITIAL_ROW)
        PIX_THREE=$(ColRowTo1D $INITIAL_COLUMN $(($INITIAL_ROW + 1)))
        PIX_FOUR=$(ColRowTo1D $(($INITIAL_COLUMN + 1)) $(($INITIAL_ROW + 1)))
        COLOR=$LIME_YELLOW
    fi

    if [ $BLOCK_TYPE -eq $Z_BLOCK ]
    then
        PIX_ONE=$(ColRowTo1D $INITIAL_COLUMN $INITIAL_ROW)
        PIX_TWO=$(ColRowTo1D $(($INITIAL_COLUMN + 1)) $INITIAL_ROW)
        PIX_THREE=$(ColRowTo1D $(($INITIAL_COLUMN + 1)) $(($INITIAL_ROW + 1)))
        PIX_FOUR=$(ColRowTo1D $(($INITIAL_COLUMN + 2)) $(($INITIAL_ROW + 1)))
        COLOR=$RED
    fi

    if [ $BLOCK_TYPE -eq $S_BLOCK ]
    then
        PIX_ONE=$(ColRowTo1D $INITIAL_COLUMN $INITIAL_ROW)
        PIX_TWO=$(ColRowTo1D $(($INITIAL_COLUMN + 1)) $INITIAL_ROW)
        PIX_THREE=$(ColRowTo1D  $INITIAL_COLUMN $(($INITIAL_ROW + 1)))
        PIX_FOUR=$(ColRowTo1D $(($INITIAL_COLUMN - 1)) $(($INITIAL_ROW + 1)))
        COLOR=$GREEN
    fi

    if [ $BLOCK_TYPE -eq $T_BLOCK ]
    then
        PIX_ONE=$(ColRowTo1D $INITIAL_COLUMN $INITIAL_ROW)
        PIX_TWO=$(ColRowTo1D $INITIAL_COLUMN $(($INITIAL_ROW + 1)))
        PIX_THREE=$(ColRowTo1D $(($INITIAL_COLUMN - 1)) $(($INITIAL_ROW + 1)))
        PIX_FOUR=$(ColRowTo1D $(($INITIAL_COLUMN + 1)) $(($INITIAL_ROW + 1)))
        COLOR=$MAGENTA
    fi

    if [ $BLOCK_TYPE -eq $I_BLOCK ]
    then
        PIX_ONE=$(ColRowTo1D $INITIAL_COLUMN $INITIAL_ROW)
        PIX_TWO=$(ColRowTo1D $(($INITIAL_COLUMN + 1)) $INITIAL_ROW)
        PIX_THREE=$(ColRowTo1D $(($INITIAL_COLUMN - 1)) $INITIAL_ROW)
        PIX_FOUR=$(ColRowTo1D $(($INITIAL_COLUMN + 2)) $INITIAL_ROW)
        COLOR=$CYAN
    fi

    if [ $BLOCK_TYPE -eq $L_BLOCK ]
    then
        PIX_ONE=$(ColRowTo1D $INITIAL_COLUMN $INITIAL_ROW)
        PIX_TWO=$(ColRowTo1D $INITIAL_COLUMN $(($INITIAL_ROW + 1)))
        PIX_THREE=$(ColRowTo1D $(($INITIAL_COLUMN + 1)) $(($INITIAL_ROW + 1)))
        PIX_FOUR=$(ColRowTo1D $(($INITIAL_COLUMN + 2)) $(($INITIAL_ROW + 1)))
        COLOR=$BLUE
    fi

    if [ $BLOCK_TYPE -eq $J_BLOCK ]
    then
        PIX_ONE=$(ColRowTo1D $INITIAL_COLUMN $INITIAL_ROW)
        PIX_TWO=$(ColRowTo1D $INITIAL_COLUMN $(($INITIAL_ROW + 1)))
        PIX_THREE=$(ColRowTo1D $(($INITIAL_COLUMN - 1)) $(($INITIAL_ROW + 1)))
        PIX_FOUR=$(ColRowTo1D $(($INITIAL_COLUMN - 2)) $(($INITIAL_ROW + 1)))
        COLOR=$YELLOW
    fi
}

function rotateZ() {
    if [ $CURRENT_ROTATION -eq $ROTATION_UP ]
    then
        ((PIX_ONE=PIX_ONE+2))
        ((PIX_TWO=PIX_TWO+WIDTH+1))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR+WIDTH-1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_RIGHT ]
    then
        ((PIX_ONE=PIX_ONE-2))
        ((PIX_TWO=PIX_TWO-WIDTH-1))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR-WIDTH+1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_DOWN ]
    then
        ((PIX_ONE=PIX_ONE+2))
        ((PIX_TWO=PIX_TWO+WIDTH+1))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR+WIDTH-1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_LEFT ]
    then
        ((PIX_ONE=PIX_ONE-2))
        ((PIX_TWO=PIX_TWO-WIDTH-1))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR-WIDTH+1))
    fi
}

function rotateS() {
    if [ $CURRENT_ROTATION -eq $ROTATION_UP ]
    then
        ((PIX_ONE=PIX_ONE+WIDTH+1))
        ((PIX_TWO=PIX_TWO+WIDTH+WIDTH))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR-WIDTH+1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_RIGHT ]
    then
        ((PIX_ONE=PIX_ONE-WIDTH-1))
        ((PIX_TWO=PIX_TWO-WIDTH-WIDTH))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR+WIDTH-1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_DOWN ]
    then
        ((PIX_ONE=PIX_ONE+WIDTH+1))
        ((PIX_TWO=PIX_TWO+WIDTH+WIDTH))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR-WIDTH+1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_LEFT ]
    then
        ((PIX_ONE=PIX_ONE-WIDTH-1))
        ((PIX_TWO=PIX_TWO-WIDTH-WIDTH))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR+WIDTH-1))
    fi
}

function rotateT() {
    if [ $CURRENT_ROTATION -eq $ROTATION_UP ]
    then
        ((PIX_ONE=PIX_ONE+WIDTH+1))
        ((PIX_TWO=PIX_TWO))
        ((PIX_THREE=PIX_THREE-WIDTH+1))
        ((PIX_FOUR=PIX_FOUR+WIDTH-1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_RIGHT ]
    then
        ((PIX_ONE=PIX_ONE-1))
        ((PIX_TWO=PIX_TWO-WIDTH))
        ((PIX_THREE=PIX_THREE+1))
        ((PIX_FOUR=PIX_FOUR-WIDTH-WIDTH-1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_DOWN ]
    then
        ((PIX_ONE=PIX_ONE))
        ((PIX_TWO=PIX_TWO+WIDTH+1))
        ((PIX_THREE=PIX_THREE+WIDTH+WIDTH))
        ((PIX_FOUR=PIX_FOUR+2))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_LEFT ]
    then
        ((PIX_ONE=PIX_ONE-WIDTH))
        ((PIX_TWO=PIX_TWO-1))
        ((PIX_THREE=PIX_THREE-WIDTH-2))
        ((PIX_FOUR=PIX_FOUR+WIDTH))
    fi
}

function rotateI() {
    if [ $CURRENT_ROTATION -eq $ROTATION_UP ]
    then
        ((PIX_ONE=PIX_ONE))
        ((PIX_TWO=PIX_TWO+WIDTH-1))
        ((PIX_THREE=PIX_THREE-WIDTH+1))
        ((PIX_FOUR=PIX_FOUR+WIDTH+WIDTH-2))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_RIGHT ]
    then
        ((PIX_ONE=PIX_ONE))
        ((PIX_TWO=PIX_TWO-WIDTH+1))
        ((PIX_THREE=PIX_THREE+WIDTH-1))
        ((PIX_FOUR=PIX_FOUR-WIDTH-WIDTH+2))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_DOWN ]
    then
        ((PIX_ONE=PIX_ONE))
        ((PIX_TWO=PIX_TWO+WIDTH-1))
        ((PIX_THREE=PIX_THREE-WIDTH+1))
        ((PIX_FOUR=PIX_FOUR+WIDTH+WIDTH-2))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_LEFT ]
    then
        ((PIX_ONE=PIX_ONE))
        ((PIX_TWO=PIX_TWO-WIDTH+1))
        ((PIX_THREE=PIX_THREE+WIDTH-1))
        ((PIX_FOUR=PIX_FOUR-WIDTH-WIDTH+2))
    fi
}

function rotateL() {
    if [ $CURRENT_ROTATION -eq $ROTATION_UP ]
    then
        ((PIX_ONE=PIX_ONE-WIDTH+1))
        ((PIX_TWO=PIX_TWO-WIDTH-WIDTH))
        ((PIX_THREE=PIX_THREE-WIDTH-1))
        ((PIX_FOUR=PIX_FOUR-2))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_RIGHT ]
    then
        ((PIX_ONE=PIX_ONE+WIDTH))
        ((PIX_TWO=PIX_TWO+1))
        ((PIX_THREE=PIX_THREE-WIDTH))
        ((PIX_FOUR=PIX_FOUR-WIDTH-WIDTH-1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_DOWN ]
    then
        ((PIX_ONE=PIX_ONE+WIDTH-1))
        ((PIX_TWO=PIX_TWO+WIDTH+WIDTH))
        ((PIX_THREE=PIX_THREE+WIDTH+1))
        ((PIX_FOUR=PIX_FOUR+2))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_LEFT ]
    then
        ((PIX_ONE=PIX_ONE-WIDTH))
        ((PIX_TWO=PIX_TWO-1))
        ((PIX_THREE=PIX_THREE+WIDTH))
        ((PIX_FOUR=PIX_FOUR+WIDTH+WIDTH+1))
    fi
}

function rotateJ() {
    if [ $CURRENT_ROTATION -eq $ROTATION_UP ]
    then
        ((PIX_ONE=PIX_ONE+WIDTH))
        ((PIX_TWO=PIX_TWO-1))
        ((PIX_THREE=PIX_THREE-WIDTH))
        ((PIX_FOUR=PIX_FOUR-WIDTH-WIDTH+1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_RIGHT ]
    then
        ((PIX_ONE=PIX_ONE-1))
        ((PIX_TWO=PIX_TWO-WIDTH))
        ((PIX_THREE=PIX_THREE+1))
        ((PIX_FOUR=PIX_FOUR+WIDTH+2))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_DOWN ]
    then
        ((PIX_ONE=PIX_ONE-WIDTH-WIDTH))
        ((PIX_TWO=PIX_TWO-WIDTH+1))
        ((PIX_THREE=PIX_THREE))
        ((PIX_FOUR=PIX_FOUR+WIDTH-1))
    fi
    if [ $CURRENT_ROTATION -eq $ROTATION_LEFT ]
    then
        ((PIX_ONE=PIX_ONE+1))
        ((PIX_TWO=PIX_TWO+WIDTH))
        ((PIX_THREE=PIX_THREE-1))
        ((PIX_FOUR=PIX_FOUR-WIDTH-2))
    fi
}



function rotateBlock() {
    clearBlock
    if [ $BLOCK_TYPE -eq $Z_BLOCK ]
    then
        rotateZ
    fi

    if [ $BLOCK_TYPE -eq $S_BLOCK ]
    then
        rotateS
    fi

    if [ $BLOCK_TYPE -eq $T_BLOCK ]
    then
        rotateT
    fi

    if [ $BLOCK_TYPE -eq $I_BLOCK ]
    then
        rotateI
    fi

    if [ $BLOCK_TYPE -eq $L_BLOCK ]
    then
        rotateL
    fi

    if [ $BLOCK_TYPE -eq $J_BLOCK ]
    then
        rotateJ
    fi
    ((CURRENT_ROTATION=CURRENT_ROTATION+1))
    ((CURRENT_ROTATION=CURRENT_ROTATION%4))
    printBlock
}

function clearBlock() {
    tput cup $(ToRow $PIX_ONE) $(ToCol $PIX_ONE)
    printf " "
    tput cup $(ToRow $PIX_TWO) $(ToCol $PIX_TWO)
    printf " "
    tput cup $(ToRow $PIX_THREE) $(ToCol $PIX_THREE)
    printf " "
    tput cup $(ToRow $PIX_FOUR) $(ToCol $PIX_FOUR)
    printf " "

    ARRAY[$PIX_ONE]=$FIELD_EMPTY
    ARRAY[$PIX_TWO]=$FIELD_EMPTY
    ARRAY[$PIX_THREE]=$FIELD_EMPTY
    ARRAY[$PIX_FOUR]=$FIELD_EMPTY

    tput cup 16 0
}

function printBlock() {
    printf "$COLOR"
    tput cup $(ToRow $PIX_ONE) $(ToCol $PIX_ONE)
    printf "O"
    tput cup $(ToRow $PIX_TWO) $(ToCol $PIX_TWO)
    printf "O"
    tput cup $(ToRow $PIX_THREE) $(ToCol $PIX_THREE)
    printf "O"
    tput cup $(ToRow $PIX_FOUR) $(ToCol $PIX_FOUR)
    printf "O"
    printf "$NORMAL"

    if [ $CAN_MOVE_DOWN -eq 0 ]
    then
        ARRAY[$PIX_ONE]=$BLOCK_TYPE
        ARRAY[$PIX_TWO]=$BLOCK_TYPE
        ARRAY[$PIX_THREE]=$BLOCK_TYPE
        ARRAY[$PIX_FOUR]=$BLOCK_TYPE
    else
        ARRAY[$PIX_ONE]=$FIELD_CURRENT
        ARRAY[$PIX_TWO]=$FIELD_CURRENT
        ARRAY[$PIX_THREE]=$FIELD_CURRENT
        ARRAY[$PIX_FOUR]=$FIELD_CURRENT
    fi

    tput cup 16 0
}

function moveBlockDown() {
    clearBlock

    local next_one next_two next_three next_four
    local arr_next_one arr_next_two arr_next_three arr_next_four

    ((next_one=PIX_ONE+WIDTH))
    ((next_two=PIX_TWO+WIDTH))
    ((next_three=PIX_THREE+WIDTH))
    ((next_four=PIX_FOUR+WIDTH))

    arr_next_one=${ARRAY[next_one]}
    arr_next_two=${ARRAY[next_two]}
    arr_next_three=${ARRAY[next_three]}
    arr_next_four=${ARRAY[next_four]}
    
    if [ "$MAX_DOWN" -lt "$HEIGHT" ]
    then
        if [[ $arr_next_one -gt $FIELD_CURRENT  ||  $arr_next_two -gt $FIELD_CURRENT  ||  $arr_next_three -gt $FIELD_CURRENT  || $arr_next_four -gt $FIELD_CURRENT ]]
        then
            CAN_MOVE_DOWN=0
        else
            ((PIX_ONE=PIX_ONE+WIDTH))
            ((PIX_TWO=PIX_TWO+WIDTH))
            ((PIX_THREE=PIX_THREE+WIDTH))
            ((PIX_FOUR=PIX_FOUR+WIDTH))
        fi
    else
        CAN_MOVE_DOWN=0
    fi
    setMaxDown $(ToRow $PIX_ONE) $(ToRow $PIX_TWO) $(ToRow $PIX_THREE) $(ToRow $PIX_FOUR)
    
    printBlock
    
}

function moveBlockLeft() {
    clearBlock
    if [ "$MIN_LEFT" -gt 0 ]
    then
        ((PIX_ONE=PIX_ONE-1))
        ((PIX_TWO=PIX_TWO-1))
        ((PIX_THREE=PIX_THREE-1))
        ((PIX_FOUR=PIX_FOUR-1))
    fi
    setMinLeft $(ToCol $PIX_ONE) $(ToCol $PIX_TWO) $(ToCol $PIX_THREE) $(ToCol $PIX_FOUR)
    printBlock
}

function moveBlockRight() {
    clearBlock
    if [ "$MAX_RIGHT" -lt "$(($WIDTH-1))" ]
    then
        ((PIX_ONE=PIX_ONE+1))
        ((PIX_TWO=PIX_TWO+1))
        ((PIX_THREE=PIX_THREE+1))
        ((PIX_FOUR=PIX_FOUR+1))
    fi
    setMaxRight $(ToCol $PIX_ONE) $(ToCol $PIX_TWO) $(ToCol $PIX_THREE) $(ToCol $PIX_FOUR)
    printBlock
}

function print() {
    
    selectBlockType
    setPixels
    setMaxRight $(ToCol $PIX_ONE) $(ToCol $PIX_TWO) $(ToCol $PIX_THREE) $(ToCol $PIX_FOUR)
    setMinLeft $(ToCol $PIX_ONE) $(ToCol $PIX_TWO) $(ToCol $PIX_THREE) $(ToCol $PIX_FOUR)
    setMaxDown $(ToRow $PIX_ONE) $(ToRow $PIX_TWO) $(ToRow $PIX_THREE) $(ToRow $PIX_FOUR)
    CURRENT_ROTATION=0
    CAN_MOVE_DOWN=1
    while [ $CAN_MOVE_DOWN -eq 1 ]
    do

        readKey

        if [ $CURRENT_ACTION -eq $ACTION_RIGHT ]
        then
            moveBlockRight
            CURRENT_ACTION=0
        fi

        if [ $CURRENT_ACTION -eq $ACTION_LEFT ]
        then
            moveBlockLeft
            CURRENT_ACTION=0
        fi

        if [ $CURRENT_ACTION -eq $ACTION_ROTATION ]
        then
            rotateBlock
            CURRENT_ACTION=0
        fi

        moveBlockDown
    done
    resetPixels
}

function readKey() {
    read -n1 -t1 key
    if [ "$key" == "a" ]
    then
        CURRENT_ACTION=$ACTION_LEFT
    fi
    if [ "$key" == "d" ]
    then
        CURRENT_ACTION=$ACTION_RIGHT
    fi
    if [ "$key" == "r" ]
    then
        CURRENT_ACTION=$ACTION_ROTATION
    fi
}

function moveRowsDown() {
    local row
    row=$1
    local position
    position=$(ColRowTo1D $j $row)
    # printf $position
    for i in $(seq $position -1 10)
    do
        local up_position
        ((up_position=$i-$WIDTH))
        ARRAY[$i]=${ARRAY[up_position]}
    done
}

function checkAndRemoveFullBlocks() {
    for i in $(seq 1 1 14)
    do
        local filled_elems
        filled_elems=0
        for j in $(seq 0 1 9)
        do
            local position
            position=$(ColRowTo1D $j $i)

            if [ ${ARRAY[position]} -gt $FIELD_CURRENT ]
            then
                ((filled_elems=filled_elems+1))
            fi

            if [ $filled_elems -eq $WIDTH ]
            then
                moveRowsDown ${i}
                ((POINTS=POINTS+10))
                reprintBoard
            fi
        done
    done
    tput cup 16 0
}

function printPoints() {
    tput cup 7 20
    printf "POINTS: $POINTS"
    tput cup 16 0
}

function checkGameOver() {
    for i in $(seq 0 1 9)
    do
        if [ ${ARRAY[i]} -gt $FIELD_CURRENT ]
        then
            printf "GAME OVER\n"
            tput cup 16 0
            exit 1
        fi
    done
}

function gameLoop() {
    while :
    do
        print
        checkAndRemoveFullBlocks
        printPoints
        checkGameOver
    done
}

tput clear
printBorders
prepareArray
gameLoop



