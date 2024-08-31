library IEEE;
use IEEE.STD_LOGIC_1164.all;

ENTITY lab2_1 IS
    PORT (
        Ain, Bin, Cin, Din : IN STD_LOGIC;
        a, b, c, d, e, f, g : OUT STD_LOGIC
    );

END lab2_1;

-- a: 0, 2, 3, 5, 6, 7, 8, 9, A, E, F
-- b: 0, 1, 2, 3, 4, 7, 8, 9, A, D
-- c: 0, 1, 3, 4, 5, 6, 7, 8, 9, A, B, D
-- d: 0, 2, 3, 5, 6, 8, 9, B, C, D, E
-- e: 0, 2, 6, 8, A, B, C, D, E, F
-- f: 0, 4, 5, 6, 8, 9, A, B, E, F
-- g: 2, 3, 4, 5, 6, 8, 9, A, B, C, D, E, F

-- 0 ~ F
-- 0:
-- ( (NOT Ain) AND (NOT Bin) AND (NOT Cin) AND (NOT Din) )
-- 1:
-- ( (NOT Ain) AND (NOT Bin) AND (NOT Cin) AND (Din)     )
-- 2:
-- ( (NOT Ain) AND (NOT Bin) AND (Cin) AND (NOT Din)     )
-- 3:
-- ( (NOT Ain) AND (NOT Bin) AND (Cin) AND (Din)         )
-- 4:
-- ( (NOT Ain) AND (Bin) AND (NOT Cin) AND (NOT Din)     )
-- 5:
-- ( (NOT Ain) AND (Bin) AND (NOT Cin) AND (Din)         )
-- 6:
-- ( (NOT Ain) AND (Bin) AND (Cin) AND (NOT Din)         )
-- 7:
-- ( (NOT Ain) AND (Bin) AND (Cin) AND (Din)             )
-- 8:
-- ( (Ain) AND (NOT Bin) AND (NOT Cin) AND (NOT Din)     )
-- 9:
-- ( (Ain) AND (NOT Bin) AND (NOT Cin) AND (Din)         )
-- A:
-- ( (Ain) AND (NOT Bin) AND (Cin) AND (NOT Din)         )
-- B:
-- ( (Ain) AND (NOT Bin) AND (Cin) AND (Din)             )
-- C:
-- ( (Ain) AND (Bin) AND (NOT Cin) AND (NOT Din)         )
-- D:
-- ( (Ain) AND (Bin) AND (NOT Cin) AND (Din)             )
-- E:
-- ( (Ain) AND (Bin) AND (Cin) AND (NOT Din)             )
-- F:
-- ( (Ain) AND (Bin) AND (Cin) AND (Din)                 )

ARCHITECTURE dataflow OF lab2_1 IS
BEGIN
    --A <= SW(3);
    --B <= SW(2);
    --C <= SW(1);
    --D <= SW(0);

    a <= ((NOT Ain) AND (NOT Bin) AND (NOT Cin) AND (Din))     -- 1
         or ( (NOT Ain) AND (Bin) AND (NOT Cin) AND (NOT Din)) -- 4
         or ( (Ain) AND (NOT Bin) AND (Cin) AND (Din)       )  -- b
         or ( (Ain) AND (Bin) AND (NOT Cin) AND (NOT Din)   )  -- c
         or ( (Ain) AND (Bin) AND (NOT Cin) AND (Din)       ); -- d

    b <= ((NOT Ain) AND (Bin) AND (NOT Cin) AND (Din)) -- 5
         or ((NOT Ain) AND (Bin) AND (Cin) AND (NOT Din))  -- 6
         or ((Ain) AND (NOT Bin) AND (Cin) AND (Din)    )  -- b
         or ((Ain) AND (Bin) AND (NOT Cin) AND (NOT Din))  -- c
         or ((Ain) AND (Bin) AND (Cin) AND (NOT Din)    )  -- E
         or ((Ain) AND (Bin) AND (Cin) AND (Din)        ); -- F

    c <= ((NOT Ain) AND (NOT Bin) AND (Cin) AND (NOT Din)) -- 2
         or ((Ain) AND (Bin) AND (NOT Cin) AND (NOT Din))  -- c
         or ((Ain) AND (Bin) AND (Cin) AND (NOT Din)    )  -- E
         or ((Ain) AND (Bin) AND (Cin) AND (Din)        ); -- F

    d <= ( (NOT Ain) AND (NOT Bin) AND (NOT Cin) AND (Din)     )     -- 1
         or ( (NOT Ain) AND (Bin) AND (NOT Cin) AND (NOT Din)     )  -- 4
         or ( (NOT Ain) AND (Bin) AND (Cin) AND (Din)             )  -- 7
         or ( (Ain) AND (NOT Bin) AND (Cin) AND (NOT Din)         )  -- A
         or ( (Ain) AND (Bin) AND (Cin) AND (Din)                 ); -- F

    e <= ( (NOT Ain) AND (NOT Bin) AND (NOT Cin) AND (Din)     )     -- 1
         or ( (NOT Ain) AND (NOT Bin) AND (Cin) AND (Din)         )  -- 3
         or ( (NOT Ain) AND (Bin) AND (NOT Cin) AND (NOT Din)     )  -- 4
         or ( (NOT Ain) AND (Bin) AND (NOT Cin) AND (Din)         )  -- 5
         or ( (NOT Ain) AND (Bin) AND (Cin) AND (Din)             )  -- 7
         or ( (Ain) AND (NOT Bin) AND (NOT Cin) AND (Din)         ); -- 9

    f <= ( (NOT Ain) AND (NOT Bin) AND (NOT Cin) AND (Din)     )     -- 1
         or ( (NOT Ain) AND (NOT Bin) AND (Cin) AND (NOT Din)     )  -- 2
         or ( (NOT Ain) AND (NOT Bin) AND (Cin) AND (Din)         )  -- 3
         or ( (NOT Ain) AND (Bin) AND (Cin) AND (Din)             )  -- 7
         or ( (Ain) AND (Bin) AND (NOT Cin) AND (NOT Din)         )  -- c
         or ( (Ain) AND (Bin) AND (NOT Cin) AND (Din)             ); -- d

    g <= ( (NOT Ain) AND (NOT Bin) AND (NOT Cin) AND (NOT Din) )     -- 0
         or ( (NOT Ain) AND (NOT Bin) AND (NOT Cin) AND (Din)     )  -- 1
         or ( (NOT Ain) AND (Bin) AND (Cin) AND (Din)             ); -- 7
END dataflow;
