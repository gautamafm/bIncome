/*
    Eyeball individual weird cases
*/
use ../data/temp, clear

/* person id 254
   Head was not in original sample, wife was. Wife divorced first husband,
   marred Head, head brought into sample.
*/
if 0 {
    gen a = interview_number_y1987 == 6631
    gen b = interview_number_y1986 == 3454
}
/* person id 495, file year 1993, lost in 1992
   Wife in 1992 was a child in initial wave, somehow got back into sample in
   1993 with new husband.
*/
if 0 {
    gen a = interview_number_y1993 == 10738
    gen b = interview_number_y1994 == 11758
}
/* person 583, file year 1990, lost 1981
   Wife was original sample, head married in.
*/
if 0 {
    gen a = interview_number_y1982 == 696
    gen b = interview_number_y1983 == 3286
}
/* person 1020, file year 1990, lost 1987
   Wife in original sample
*/
if 1 {
    gen a = interview_number_y1989 == 2533
    gen b = interview_number_y1988 == 2535
}

foreach y of numlist 2007(-2)1999 1997(-1)1969 {
    order interview_number_y`y' relhead_y`y' sequence_number_y`y'
}
order person_id
keep interview* relhead* sequence* person_id a b 
browse if a == 1 | b == 1

