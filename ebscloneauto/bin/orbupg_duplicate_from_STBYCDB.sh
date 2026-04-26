run {
ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
ALLOCATE CHANNEL c2 DEVICE TYPE DISK;
ALLOCATE CHANNEL c3 DEVICE TYPE DISK;
ALLOCATE CHANNEL c4 DEVICE TYPE DISK;
ALLOCATE CHANNEL c5 DEVICE TYPE DISK;
ALLOCATE CHANNEL c6 DEVICE TYPE DISK; 
ALLOCATE CHANNEL c7 DEVICE TYPE DISK;
ALLOCATE CHANNEL c8 DEVICE TYPE DISK;
ALLOCATE CHANNEL c9 DEVICE TYPE DISK;
ALLOCATE CHANNEL c10 DEVICE TYPE DISK;
Allocate auxiliary channel prmy1 type  DISK;
Allocate auxiliary channel prmy2 type  DISK;
Allocate auxiliary channel prmy3 type  DISK;
Allocate auxiliary channel prmy4 type  DISK;
Allocate auxiliary channel prmy5 type  DISK;
Allocate auxiliary channel prmy6 type  DISK;
Allocate auxiliary channel prmy7 type  DISK;
Allocate auxiliary channel prmy8 type  DISK;
Allocate auxiliary channel prmy9 type  DISK;
Allocate auxiliary channel prmy10 type  DISK;
DUPLICATE TARGET DATABASE TO ORBUPGCD from active database nofilenamecheck;
}

