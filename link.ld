SECTIONS
{
    /* boot loader starts at 0x7C00 */
    . = 0x7C00;
    .boot0 : 
    {
        _boot0_start = .;
        objs/boot0.o(.text*)
        _boot0_end = .;
    }

    ASSERT(_boot0_start == 0x7C00, "Boot 0 must be loaded in at 0x7C00")
    ASSERT(_boot0_end == 0x7E00, "Something went wrong linking boot0")

    /* boot1 begins directly after boot0 */
    . = 0x7E00;
    .boot1 :
    {
        _boot1_start = .;
        objs/boot1.o(.text*)
        _boot1_end = .;
    }
    ASSERT(_boot1_end == 0x8000, "Something went wrong linking boot1")
}
