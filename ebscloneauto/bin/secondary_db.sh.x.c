#if 0
	shc Version 4.0.3, Generic Shell Script Compiler
	GNU GPL Version 3 Md Jahidul Hamid <jahidulhamid@yahoo.com>

	shc -e 12/31/2028 -m License Expired. Please contact support@candidsource.com -r -o secondary_db.bin -f secondary_db.sh 
#endif

static  char data [] = 
#define      tst1_z	22
#define      tst1	((&data[2]))
	"\322\364\054\103\047\257\161\271\105\211\046\163\277\317\014\052"
	"\241\213\220\161\212\111\306\220\063\367\276\324"
#define      msg1_z	70
#define      msg1	((&data[45]))
	"\237\204\215\274\142\302\335\240\137\244\263\046\342\327\200\331"
	"\166\275\253\164\025\304\252\000\313\304\323\305\242\241\202\157"
	"\005\247\047\277\111\163\110\265\030\171\232\265\102\261\277\072"
	"\323\263\213\142\344\221\217\314\074\366\234\256\365\377\100\064"
	"\015\016\040\236\013\014\174\207\164\051\226\333\325\311\251\326"
	"\033\264\302\210\116\305\313\244\241\375\000\161\317\365\245\307"
	"\263"
#define      chk1_z	22
#define      chk1	((&data[130]))
	"\025\200\062\242\074\333\114\334\353\156\150\365\345\065\233\045"
	"\353\171\311\213\203\102\010\064\065\136\047\225\144\032\065"
#define      opts_z	1
#define      opts	((&data[156]))
	"\151"
#define      tst2_z	19
#define      tst2	((&data[160]))
	"\153\172\066\252\316\155\120\044\224\151\110\241\136\255\263\137"
	"\217\163\212\162\123\375\017\033\063"
#define      pswd_z	256
#define      pswd	((&data[217]))
	"\006\063\313\271\255\254\147\302\054\231\145\150\057\312\203\144"
	"\216\102\114\171\343\015\344\135\103\364\171\167\005\007\173\013"
	"\072\107\304\032\102\011\113\347\166\347\324\222\130\123\374\314"
	"\020\240\163\104\060\110\066\315\007\323\234\111\274\206\126\051"
	"\234\061\104\336\073\217\306\261\166\232\103\316\356\100\233\376"
	"\340\017\103\020\127\171\335\136\115\172\250\011\000\377\062\234"
	"\060\167\173\153\006\101\035\175\333\141\114\312\241\350\310\202"
	"\367\013\223\117\205\161\256\322\353\126\333\353\125\016\210\206"
	"\205\003\362\214\104\020\011\040\161\126\352\023\076\263\225\065"
	"\277\050\204\104\231\062\027\204\211\362\160\337\001\370\145\207"
	"\374\130\023\101\150\035\142\331\163\115\355\261\001\203\346\300"
	"\253\153\005\105\235\035\312\047\017\072\006\021\063\154\230\060"
	"\304\253\161\054\311\323\006\074\041\363\355\042\167\324\343\042"
	"\077\350\150\335\005\062\004\025\155\013\047\241\167\277\321\073"
	"\153\103\150\064\026\156\160\070\142\136\132\331\062\075\374\161"
	"\046\144\117\054\226\123\101\004\136\151\245\326\050\166\021\224"
	"\271\171\310\320\350\071\010\113\227\143\045\311\240\041\073\306"
	"\206\212\362\035\336\064\041\075\235\306\023\306\075\044\132\367"
	"\236\043\307"
#define      chk2_z	19
#define      chk2	((&data[477]))
	"\253\037\306\020\230\052\223\032\062\007\101\274\104\375\303\203"
	"\216\056\225\270\004\124\010"
#define      msg2_z	19
#define      msg2	((&data[500]))
	"\013\131\151\115\324\267\220\117\304\240\051\126\003\235\360\235"
	"\056\052\060\111\055\337\323\246\342\061\264"
#define      text_z	1647
#define      text	((&data[753]))
	"\273\011\157\301\020\353\314\113\062\221\063\045\275\336\104\204"
	"\357\315\171\311\330\323\062\046\172\025\130\056\334\347\046\230"
	"\360\225\131\001\200\045\114\262\267\200\330\165\136\035\371\116"
	"\352\162\027\303\106\112\351\300\137\102\356\073\051\024\324\032"
	"\252\055\033\053\123\150\336\012\350\266\200\107\323\171\225\275"
	"\354\255\200\062\370\152\363\127\254\341\223\326\366\147\361\241"
	"\225\015\314\351\165\252\363\136\141\164\245\064\355\073\362\331"
	"\350\163\014\340\336\377\070\213\341\314\142\327\063\123\171\311"
	"\141\106\262\326\361\246\064\122\032\332\207\007\025\172\341\376"
	"\356\355\337\314\354\030\130\315\344\272\245\030\016\037\341\157"
	"\145\223\106\126\072\172\251\124\125\060\134\153\253\075\151\231"
	"\053\111\145\030\141\276\346\105\170\214\135\207\253\077\366\021"
	"\323\074\150\015\267\021\141\014\102\276\167\355\373\341\206\047"
	"\052\354\077\214\252\045\321\043\262\057\252\135\156\241\157\102"
	"\335\327\117\225\350\261\020\164\106\344\342\325\125\273\210\012"
	"\147\246\257\171\305\026\235\161\066\245\241\211\034\356\336\354"
	"\334\245\113\233\336\206\250\162\252\236\172\210\124\102\205\247"
	"\254\011\374\360\123\132\047\122\355\262\006\170\236\215\102\012"
	"\046\256\334\302\161\040\302\145\342\222\136\307\330\117\135\037"
	"\366\211\236\233\144\177\240\122\012\322\334\016\040\124\276\024"
	"\010\306\245\034\004\323\053\167\164\327\136\111\216\124\134\245"
	"\102\013\026\315\151\142\230\002\025\130\237\357\103\241\165\240"
	"\010\363\230\063\025\335\143\236\023\012\117\107\010\207\207\334"
	"\067\316\224\132\307\000\134\323\172\041\153\240\111\066\317\374"
	"\354\113\031\166\231\045\375\371\250\362\163\165\067\335\111\324"
	"\225\040\137\311\311\046\075\032\001\140\274\057\162\312\001\356"
	"\141\035\302\363\321\075\323\173\353\255\300\136\235\037\013\102"
	"\233\210\321\164\047\236\236\331\056\332\142\230\303\371\176\026"
	"\272\324\022\360\265\331\055\321\070\252\355\206\242\005\134\351"
	"\076\303\144\006\231\025\000\370\026\231\250\151\015\351\103\241"
	"\330\354\136\156\023\363\361\055\273\364\102\056\154\031\365\314"
	"\377\262\176\207\331\021\222\365\245\074\112\163\017\150\226\325"
	"\352\104\147\010\365\346\077\016\073\352\222\010\367\123\357\175"
	"\260\302\331\261\345\332\274\217\233\137\161\335\326\222\127\246"
	"\156\016\122\140\063\160\103\175\000\337\217\126\002\350\047\340"
	"\262\336\366\234\135\073\275\227\303\332\142\147\070\132\204\310"
	"\271\147\277\120\315\142\060\070\247\225\375\116\122\153\211\227"
	"\151\060\204\115\170\165\374\367\065\316\127\023\233\155\166\070"
	"\100\163\271\310\315\326\000\357\204\063\156\156\257\367\001\005"
	"\322\037\004\171\263\144\027\177\076\336\322\311\277\120\013\255"
	"\306\112\065\152\226\146\260\351\124\135\270\367\000\310\357\040"
	"\040\347\243\212\164\033\256\125\213\232\277\033\143\256\020\341"
	"\012\134\322\171\360\053\333\113\332\364\315\116\111\005\151\215"
	"\224\275\277\111\374\123\076\276\153\056\010\375\244\161\330\003"
	"\242\360\261\257\017\114\004\326\027\353\173\331\264\052\226\046"
	"\326\052\237\367\251\236\235\237\106\252\233\144\230\351\132\067"
	"\041\360\302\112\012\371\071\125\232\254\246\071\063\067\245\375"
	"\262\323\204\060\063\345\047\214\132\167\047\212\025\377\363\025"
	"\110\052\065\360\027\057\110\154\122\151\005\146\336\003\141\002"
	"\064\063\354\355\153\213\032\310\123\065\314\004\067\265\362\144"
	"\254\221\313\064\045\003\255\271\163\155\015\152\173\023\277\273"
	"\014\001\154\360\166\362\255\330\240\103\265\331\267\124\135\151"
	"\134\160\213\241\025\355\324\323\065\164\151\201\112\213\222\030"
	"\145\074\377\170\155\366\001\264\070\345\356\307\361\250\332\167"
	"\056\241\047\050\323\110\313\111\212\361\202\011\306\274\100\021"
	"\255\164\165\121\277\327\304\153\373\056\200\324\253\254\006\012"
	"\047\350\340\076\133\117\324\350\073\131\322\142\265\136\345\247"
	"\367\135\047\035\040\157\312\117\060\020\124\331\243\336\240\272"
	"\011\276\122\053\204\364\031\313\305\337\276\212\204\240\116\140"
	"\033\065\027\230\137\330\162\161\236\142\165\263\367\372\210\053"
	"\074\161\355\106\305\114\070\110\272\023\160\250\125\124\211\122"
	"\344\172\215\112\361\065\111\315\027\226\157\002\340\343\144\224"
	"\110\137\200\056\066\062\010\375\344\006\355\336\312\365\062\136"
	"\127\320\033\343\134\255\352\304\253\011\020\203\261\345\046\032"
	"\321\043\275\243\124\370\345\131\366\140\321\266\325\256\235\070"
	"\326\171\237\041\266\132\367\026\334\307\321\210\333\111\133\053"
	"\124\357\044\026\106\323\041\371\113\252\212\155\217\052\226\113"
	"\213\014\061\056\076\347\022\215\154\264\333\066\221\246\336\255"
	"\031\015\066\352\357\363\240\140\260\021\016\210\303\310\217\221"
	"\103\333\122\236\256\033\351\154\322\042\271\114\263\321\030\227"
	"\334\144\134\037\125\316\310\163\104\302\372\232\320\130\105\071"
	"\326\111\147\005\071\225\202\275\206\130\366\357\170\263\271\217"
	"\125\113\350\145\203\103\040\142\053\274\252\300\213\124\032\373"
	"\206\064\267\251\135\176\276\046\150\073\270\112\236\332\013\366"
	"\044\201\167\274\206\307\162\204\170\016\153\306\357\122\336\113"
	"\244\014\042\145\027\100\053\333\261\137\167\307\206\354\216\242"
	"\332\360\311\125\370\274\137\137\013\136\362\371\324\342\213\045"
	"\010\271\205\251\126\306\255\032\170\040\234\355\226\144\013\102"
	"\115\033\137\303\041\263\000\201\067\101\370\253\313\053\105\253"
	"\132\375\151\210\012\036\014\225\122\165\006\355\000\142\136\251"
	"\202\330\116\311\340\010\256\050\004\171\176\167\202\050\050\257"
	"\116\240\022\307\276\207\360\032\153\075\111\253\005\325\173\215"
	"\036\050\014\143\336\264\347\020\305\365\131\114\320\204\206\250"
	"\153\366\045\203\226\012\312\162\015\045\336\314\004\274\221\240"
	"\267\067\036\141\266\040\152\263\346\111\024\005\274\100\347\372"
	"\223\247\313\045\227\046\235\207\351\267\100\101\036\260\045\342"
	"\301\053\164\323\311\071\161\300\270\111\253\352\171\347\032\275"
	"\367\141\234\077\021\376\013\362\067\175\271\304\177\042\214\103"
	"\041\177\221\347\376\266\136\120\025\355\047\227\323\204\260\044"
	"\126\365\335\374\134\007\264\273\117\376\225\141\353\323\324\301"
	"\207\015\070\000\107\300\033\101\012\100\245\140\220\104\326\226"
	"\324\346\306\200\217\272\314\261\153\043\070\352\310\047\166\250"
	"\167\226\274\216\142\267\205\027\033\272\134\134\123\012\026\123"
	"\175\243\062\127\302\005\064\320\111\064\377\144\035\133\262\034"
	"\247\271\167\220\020\060\106\060\143\221\366\115\166\160\322\005"
	"\202\161\352\250\254\365\216\112\304\306\165\263\010\147\265\166"
	"\014\271\157\164\020\274\206\072\135\206\231\167\031\121\037\053"
	"\003\154\112\371\171\337\061\342\135\046\003\224\270\224\144\205"
	"\356\053\035\116\172\301\332\031\166\116\123\007\076\360\026\055"
	"\206\346\344\327\213\235\376\251\342\067\320\136\054\017\142\016"
	"\250\153\334\131\102\052\121\026\340\266\101\013\265\052\202\332"
	"\223\275\163\244\327\232\334\233\350\325\050\212\232\134\165\272"
	"\031\175\137\333\174\106\046\376\173\060\212\252\253\304\351\103"
	"\134\107\103\241\220\215\300\346\366\302\101\105\143\225\366\134"
	"\051\223\051\117\123\312\375\044\210\254\117\325\203\220\244\016"
	"\144\317\366\267\216\324\361\033\274\047\007\053\052\155\300\353"
	"\107\366\062\067\117\005\021\355\247\357\030\210\113\252\175\374"
	"\146\360\105\327\020\356\244\342\370\177\372\371\351\222\172\050"
	"\176\361\227\071\045\177\214\155\160\341\225\122\004\360\115\352"
	"\355\323\320\146\204\220\161\124\156\322\326\104\223\224\203\253"
	"\042\052\334\240\166\155\134\166\000\335\211\067\077\230\327\242"
	"\356\037\062\017\242\131\116\371\075\016\343\373\211\033\207\133"
	"\203\330\205\334\303\055\314\374\006\075\345\150\126\141\173\133"
	"\335\074\242\370\347\144\012\005\070\250\063\214\123\354\120\302"
	"\261\051\347\251\066\202\071\134\336\134\344\237\004\211\014\233"
	"\352\272\360\325\074\226\173\053\266\025\337\345\150\354\021\322"
	"\201\315\024\010\023\143\036\336\017\374\333\034\167\366\132\074"
	"\367\154\270\376\371\241\052\157\031\030\153\373\236\222\046\213"
	"\322\262\065\370\204\131\252\264\003\010\043\244\167\145\202\116"
	"\264\027\066\145\271\141\325\323\172\100\316\030\323\365\243\245"
	"\247\331\235\054\062\110\340\066\120\003\333\307\150\136\026\035"
	"\166\115\202\057\257\130\003\051\230\322\101\153\307\345\021\157"
	"\277\256\233\362\367\174\050\107\177\004\017\350\143\046\005\331"
	"\163\210\011\042\340\014\113\171\337\215\344\246\163\366\026\062"
	"\244\262\044\234\056\115\344\256\122\364\227\265\032\235\216\215"
	"\046\227\260\007\244\374\200\203\211\145\052\375\133\101\057\000"
	"\363\124\234\042\242\200\321\365\165\151\252\217\006\071\035\054"
	"\321\316\063\166\312\264\372\124\031\044\121\164\145\201\165\131"
	"\326\021\173\171\222\115\156\010\266\031\227\274\123\265\351\045"
	"\203\035\233\116\321\225\242\352\272\364\137\040\166\325\171\115"
	"\347\365\306\171\102\065\202\370\117\031\265\243\316\236\310\122"
	"\274\144\240\215\372\102\170\264\067\330\324\255\255\116\373\224"
	"\103\301\016\206\367\220\176\107\252\064\352\171\323\263\313\217"
	"\027\153\035\021\256\225\305\346\155\232\224\033\350\217\257\054"
	"\121\276\262\110\117\061\220\371\145\172\162\071\055\075\310\104"
	"\251\345\126\130\173\033\076\351\266\322\004\237\141\264\313\262"
	"\162\175\373\301\257\213\273\025\005\055\116\063\153\027\170\024"
	"\375\316\154\170\352\253\141\240\175\145\100\336\032\013\221\215"
	"\211\214\116\070\027\011\116\035\067\234\120\242\264\310\267\261"
	"\227\044\051\201\317\213\042\114\361\142\053\013\155\274\230\367"
	"\110\347\060\140\361\176\176\050\033\317\313\317\230\203\200\057"
	"\247\252\260\166\065\323\303\046\065\356\061\243\253\312\232\364"
	"\261\312\124"
#define      rlax_z	1
#define      rlax	((&data[2798]))
	"\100"
#define      date_z	11
#define      date	((&data[2800]))
	"\227\153\374\336\077\061\063\200\211\351\104\235\063"
#define      shll_z	10
#define      shll	((&data[2812]))
	"\244\117\051\034\050\377\016\252\211\101\152\302"
#define      xecc_z	15
#define      xecc	((&data[2824]))
	"\123\357\101\367\021\161\317\155\371\120\364\345\247\040\060"
#define      inlo_z	3
#define      inlo	((&data[2839]))
	"\231\230\230"
#define      lsto_z	1
#define      lsto	((&data[2842]))
	"\145"/* End of data[] */;
#define      hide_z	4096
#define SETUID 0	/* Define as 1 to call setuid(0) at start of script */
#define DEBUGEXEC	0	/* Define as 1 to debug execvp calls */
#define TRACEABLE	1	/* Define as 1 to enable ptrace the executable */
#define HARDENING	0	/* Define as 1 to disable ptrace/dump the executable */
#define BUSYBOXON	0	/* Define as 1 to enable work with busybox */

#if HARDENING
static const char * shc_x[] = {
"/*",
" * Copyright 2019 - Intika <intika@librefox.org>",
" * Replace ******** with secret read from fd 21",
" * Also change arguments location of sub commands (sh script commands)",
" * gcc -Wall -fpic -shared -o shc_secret.so shc_secret.c -ldl",
" */",
"",
"#define _GNU_SOURCE /* needed to get RTLD_NEXT defined in dlfcn.h */",
"#define PLACEHOLDER \"********\"",
"#include <dlfcn.h>",
"#include <stdlib.h>",
"#include <string.h>",
"#include <unistd.h>",
"#include <stdio.h>",
"#include <signal.h>",
"",
"static char secret[128000]; //max size",
"typedef int (*pfi)(int, char **, char **);",
"static pfi real_main;",
"",
"// copy argv to new location",
"char **copyargs(int argc, char** argv){",
"    char **newargv = malloc((argc+1)*sizeof(*argv));",
"    char *from,*to;",
"    int i,len;",
"",
"    for(i = 0; i<argc; i++){",
"        from = argv[i];",
"        len = strlen(from)+1;",
"        to = malloc(len);",
"        memcpy(to,from,len);",
"        // zap old argv space",
"        memset(from,'\\0',len);",
"        newargv[i] = to;",
"        argv[i] = 0;",
"    }",
"    newargv[argc] = 0;",
"    return newargv;",
"}",
"",
"static int mymain(int argc, char** argv, char** env) {",
"    //fprintf(stderr, \"Inject main argc = %d\\n\", argc);",
"    return real_main(argc, copyargs(argc,argv), env);",
"}",
"",
"int __libc_start_main(int (*main) (int, char**, char**),",
"                      int argc,",
"                      char **argv,",
"                      void (*init) (void),",
"                      void (*fini)(void),",
"                      void (*rtld_fini)(void),",
"                      void (*stack_end)){",
"    static int (*real___libc_start_main)() = NULL;",
"    int n;",
"",
"    if (!real___libc_start_main) {",
"        real___libc_start_main = dlsym(RTLD_NEXT, \"__libc_start_main\");",
"        if (!real___libc_start_main) abort();",
"    }",
"",
"    n = read(21, secret, sizeof(secret));",
"    if (n > 0) {",
"      int i;",
"",
"    if (secret[n - 1] == '\\n') secret[--n] = '\\0';",
"    for (i = 1; i < argc; i++)",
"        if (strcmp(argv[i], PLACEHOLDER) == 0)",
"          argv[i] = secret;",
"    }",
"",
"    real_main = main;",
"",
"    return real___libc_start_main(mymain, argc, argv, init, fini, rtld_fini, stack_end);",
"}",
"",
0};
#endif /* HARDENING */

/* rtc.c */

#include <sys/stat.h>
#include <sys/types.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

/* 'Alleged RC4' */

static unsigned char stte[256], indx, jndx, kndx;

/*
 * Reset arc4 stte. 
 */
void stte_0(void)
{
	indx = jndx = kndx = 0;
	do {
		stte[indx] = indx;
	} while (++indx);
}

/*
 * Set key. Can be used more than once. 
 */
void key(void * str, int len)
{
	unsigned char tmp, * ptr = (unsigned char *)str;
	while (len > 0) {
		do {
			tmp = stte[indx];
			kndx += tmp;
			kndx += ptr[(int)indx % len];
			stte[indx] = stte[kndx];
			stte[kndx] = tmp;
		} while (++indx);
		ptr += 256;
		len -= 256;
	}
}

/*
 * Crypt data. 
 */
void arc4(void * str, int len)
{
	unsigned char tmp, * ptr = (unsigned char *)str;
	while (len > 0) {
		indx++;
		tmp = stte[indx];
		jndx += tmp;
		stte[indx] = stte[jndx];
		stte[jndx] = tmp;
		tmp += stte[indx];
		*ptr ^= stte[tmp];
		ptr++;
		len--;
	}
}

/* End of ARC4 */

#if HARDENING

#include <sys/ptrace.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/prctl.h>
#define PR_SET_PTRACER 0x59616d61

/* Seccomp Sandboxing Init */
#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
#include <sys/socket.h>

#include <linux/filter.h>
#include <linux/seccomp.h>
#include <linux/audit.h>

#define ArchField offsetof(struct seccomp_data, arch)

#define Allow(syscall) \
    BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, SYS_##syscall, 0, 1), \
    BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_ALLOW)

struct sock_filter filter[] = {
    /* validate arch */
    BPF_STMT(BPF_LD+BPF_W+BPF_ABS, ArchField),
    BPF_JUMP( BPF_JMP+BPF_JEQ+BPF_K, AUDIT_ARCH_X86_64, 1, 0),
    BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_KILL),

    /* load syscall */
    BPF_STMT(BPF_LD+BPF_W+BPF_ABS, offsetof(struct seccomp_data, nr)),

    /* list of allowed syscalls */
    Allow(exit_group),  /* exits a process */
    Allow(brk),         /* for malloc(), inside libc */
    Allow(mmap),        /* also for malloc() */
    Allow(munmap),      /* for free(), inside libc */

    /* and if we don't match above, die */
    BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_KILL),
};
struct sock_fprog filterprog = {
    .len = sizeof(filter)/sizeof(filter[0]),
    .filter = filter
};

/* Seccomp Sandboxing - Set up the restricted environment */
void seccomp_hardening() {
    if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
        perror("Could not start seccomp:");
        exit(1);
    }
    if (prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &filterprog) == -1) {
        perror("Could not start seccomp:");
        exit(1);
    }
} 
/* End Seccomp Sandboxing Init */

void shc_x_file() {
    FILE *fp;
    int line = 0;

    if ((fp = fopen("/tmp/shc_x.c", "w")) == NULL ) {exit(1); exit(1);}
    for (line = 0; shc_x[line]; line++)	fprintf(fp, "%s\n", shc_x[line]);
    fflush(fp);fclose(fp);
}

int make() {
	char * cc, * cflags, * ldflags;
    char cmd[4096];

	cc = getenv("CC");
	if (!cc) cc = "cc";

	sprintf(cmd, "%s %s -o %s %s", cc, "-Wall -fpic -shared", "/tmp/shc_x.so", "/tmp/shc_x.c -ldl");
	if (system(cmd)) {remove("/tmp/shc_x.c"); return -1;}
	remove("/tmp/shc_x.c"); return 0;
}

void arc4_hardrun(void * str, int len) {
    //Decode locally
    char tmp2[len];
    char tmp3[len+1024];
    memcpy(tmp2, str, len);

	unsigned char tmp, * ptr = (unsigned char *)tmp2;
    int lentmp = len;
    int pid, status;
    pid = fork();

    shc_x_file();
    if (make()) {exit(1);}

    setenv("LD_PRELOAD","/tmp/shc_x.so",1);

    if(pid==0) {

        //Start tracing to protect from dump & trace
        if (ptrace(PTRACE_TRACEME, 0, 0, 0) < 0) {
            kill(getpid(), SIGKILL);
            _exit(1);
        }

        //Decode Bash
        while (len > 0) {
            indx++;
            tmp = stte[indx];
            jndx += tmp;
            stte[indx] = stte[jndx];
            stte[jndx] = tmp;
            tmp += stte[indx];
            *ptr ^= stte[tmp];
            ptr++;
            len--;
        }

        //Do the magic
        sprintf(tmp3, "%s %s", "'********' 21<<<", tmp2);

        //Exec bash script //fork execl with 'sh -c'
        system(tmp2);

        //Empty script variable
        memcpy(tmp2, str, lentmp);

        //Clean temp
        remove("/tmp/shc_x.so");

        //Sinal to detach ptrace
        ptrace(PTRACE_DETACH, 0, 0, 0);
        exit(0);
    }
    else {wait(&status);}

    /* Seccomp Sandboxing - Start */
    seccomp_hardening();

    exit(0);
}
#endif /* HARDENING */

/*
 * Key with file invariants. 
 */
int key_with_file(char * file)
{
	struct stat statf[1];
	struct stat control[1];

	if (stat(file, statf) < 0)
		return -1;

	/* Turn on stable fields */
	memset(control, 0, sizeof(control));
	control->st_ino = statf->st_ino;
	control->st_dev = statf->st_dev;
	control->st_rdev = statf->st_rdev;
	control->st_uid = statf->st_uid;
	control->st_gid = statf->st_gid;
	control->st_size = statf->st_size;
	control->st_mtime = statf->st_mtime;
	control->st_ctime = statf->st_ctime;
	key(control, sizeof(control));
	return 0;
}

#if DEBUGEXEC
void debugexec(char * sh11, int argc, char ** argv)
{
	int i;
	fprintf(stderr, "shll=%s\n", sh11 ? sh11 : "<null>");
	fprintf(stderr, "argc=%d\n", argc);
	if (!argv) {
		fprintf(stderr, "argv=<null>\n");
	} else { 
		for (i = 0; i <= argc ; i++)
			fprintf(stderr, "argv[%d]=%.60s\n", i, argv[i] ? argv[i] : "<null>");
	}
}
#endif /* DEBUGEXEC */

void rmarg(char ** argv, char * arg)
{
	for (; argv && *argv && *argv != arg; argv++);
	for (; argv && *argv; argv++)
		*argv = argv[1];
}

void chkenv_end(void);

int chkenv(int argc)
{
	char buff[512];
	unsigned long mask, m;
	int l, a, c;
	char * string;
	extern char ** environ;

	mask = (unsigned long)getpid();
	stte_0();
	 key(&chkenv, (void*)&chkenv_end - (void*)&chkenv);
	 key(&data, sizeof(data));
	 key(&mask, sizeof(mask));
	arc4(&mask, sizeof(mask));
	sprintf(buff, "x%lx", mask);
	string = getenv(buff);
#if DEBUGEXEC
	fprintf(stderr, "getenv(%s)=%s\n", buff, string ? string : "<null>");
#endif
	l = strlen(buff);
	if (!string) {
		/* 1st */
		sprintf(&buff[l], "=%lu %d", mask, argc);
		putenv(strdup(buff));
		return 0;
	}
	c = sscanf(string, "%lu %d%c", &m, &a, buff);
	if (c == 2 && m == mask) {
		/* 3rd */
		rmarg(environ, &string[-l - 1]);
		return 1 + (argc - a);
	}
	return -1;
}

void chkenv_end(void){}

#if HARDENING

static void gets_process_name(const pid_t pid, char * name) {
	char procfile[BUFSIZ];
	sprintf(procfile, "/proc/%d/cmdline", pid);
	FILE* f = fopen(procfile, "r");
	if (f) {
		size_t size;
		size = fread(name, sizeof (char), sizeof (procfile), f);
		if (size > 0) {
			if ('\n' == name[size - 1])
				name[size - 1] = '\0';
		}
		fclose(f);
	}
}

void hardening() {
    prctl(PR_SET_DUMPABLE, 0);
    prctl(PR_SET_PTRACER, -1);

    int pid = getppid();
    char name[256] = {0};
    gets_process_name(pid, name);

    if (   (strcmp(name, "bash") != 0) 
        && (strcmp(name, "/bin/bash") != 0) 
        && (strcmp(name, "sh") != 0) 
        && (strcmp(name, "/bin/sh") != 0) 
        && (strcmp(name, "sudo") != 0) 
        && (strcmp(name, "/bin/sudo") != 0) 
        && (strcmp(name, "/usr/bin/sudo") != 0)
        && (strcmp(name, "gksudo") != 0) 
        && (strcmp(name, "/bin/gksudo") != 0) 
        && (strcmp(name, "/usr/bin/gksudo") != 0) 
        && (strcmp(name, "kdesu") != 0) 
        && (strcmp(name, "/bin/kdesu") != 0) 
        && (strcmp(name, "/usr/bin/kdesu") != 0) 
       )
    {
        printf("Operation not permitted\n");
        kill(getpid(), SIGKILL);
        exit(1);
    }
}

#endif /* HARDENING */

#if !TRACEABLE

#define _LINUX_SOURCE_COMPAT
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#if !defined(PT_ATTACHEXC) /* New replacement for PT_ATTACH */
   #if !defined(PTRACE_ATTACH) && defined(PT_ATTACH)
       #define PT_ATTACHEXC	PT_ATTACH
   #elif defined(PTRACE_ATTACH)
       #define PT_ATTACHEXC PTRACE_ATTACH
   #endif
#endif

void untraceable(char * argv0)
{
	char proc[80];
	int pid, mine;

	switch(pid = fork()) {
	case  0:
		pid = getppid();
		/* For problematic SunOS ptrace */
#if defined(__FreeBSD__)
		sprintf(proc, "/proc/%d/mem", (int)pid);
#else
		sprintf(proc, "/proc/%d/as",  (int)pid);
#endif
		close(0);
		mine = !open(proc, O_RDWR|O_EXCL);
		if (!mine && errno != EBUSY)
			mine = !ptrace(PT_ATTACHEXC, pid, 0, 0);
		if (mine) {
			kill(pid, SIGCONT);
		} else {
			perror(argv0);
			kill(pid, SIGKILL);
		}
		_exit(mine);
	case -1:
		break;
	default:
		if (pid == waitpid(pid, 0, 0))
			return;
	}
	perror(argv0);
	_exit(1);
}
#endif /* !TRACEABLE */

char * xsh(int argc, char ** argv)
{
	char * scrpt;
	int ret, i, j;
	char ** varg;
	char * me = argv[0];
	if (me == NULL) { me = getenv("_"); }
	if (me == 0) { fprintf(stderr, "E: neither argv[0] nor $_ works."); exit(1); }

	ret = chkenv(argc);
	stte_0();
	 key(pswd, pswd_z);
	arc4(msg1, msg1_z);
	arc4(date, date_z);
	if (date[0] && (atoll(date)<time(NULL)))
		return msg1;
	arc4(shll, shll_z);
	arc4(inlo, inlo_z);
	arc4(xecc, xecc_z);
	arc4(lsto, lsto_z);
	arc4(tst1, tst1_z);
	 key(tst1, tst1_z);
	arc4(chk1, chk1_z);
	if ((chk1_z != tst1_z) || memcmp(tst1, chk1, tst1_z))
		return tst1;
	arc4(msg2, msg2_z);
	if (ret < 0)
		return msg2;
	varg = (char **)calloc(argc + 10, sizeof(char *));
	if (!varg)
		return 0;
	if (ret) {
		arc4(rlax, rlax_z);
		if (!rlax[0] && key_with_file(shll))
			return shll;
		arc4(opts, opts_z);
#if HARDENING
	    arc4_hardrun(text, text_z);
	    exit(0);
       /* Seccomp Sandboxing - Start */
       seccomp_hardening();
#endif
		arc4(text, text_z);
		arc4(tst2, tst2_z);
		 key(tst2, tst2_z);
		arc4(chk2, chk2_z);
		if ((chk2_z != tst2_z) || memcmp(tst2, chk2, tst2_z))
			return tst2;
		/* Prepend hide_z spaces to script text to hide it. */
		scrpt = malloc(hide_z + text_z);
		if (!scrpt)
			return 0;
		memset(scrpt, (int) ' ', hide_z);
		memcpy(&scrpt[hide_z], text, text_z);
	} else {			/* Reexecute */
		if (*xecc) {
			scrpt = malloc(512);
			if (!scrpt)
				return 0;
			sprintf(scrpt, xecc, me);
		} else {
			scrpt = me;
		}
	}
	j = 0;
#if BUSYBOXON
	varg[j++] = "busybox";
	varg[j++] = "sh";
#else
	varg[j++] = argv[0];		/* My own name at execution */
#endif
	if (ret && *opts)
		varg[j++] = opts;	/* Options on 1st line of code */
	if (*inlo)
		varg[j++] = inlo;	/* Option introducing inline code */
	varg[j++] = scrpt;		/* The script itself */
	if (*lsto)
		varg[j++] = lsto;	/* Option meaning last option */
	i = (ret > 1) ? ret : 0;	/* Args numbering correction */
	while (i < argc)
		varg[j++] = argv[i++];	/* Main run-time arguments */
	varg[j] = 0;			/* NULL terminated array */
#if DEBUGEXEC
	debugexec(shll, j, varg);
#endif
	execvp(shll, varg);
	return shll;
}

int main(int argc, char ** argv)
{
#if SETUID
   setuid(0);
#endif
#if DEBUGEXEC
	debugexec("main", argc, argv);
#endif
#if HARDENING
	hardening();
#endif
#if !TRACEABLE
	untraceable(argv[0]);
#endif
	argv[1] = xsh(argc, argv);
	fprintf(stderr, "%s%s%s: %s\n", argv[0],
		errno ? ": " : "",
		errno ? strerror(errno) : "",
		argv[1] ? argv[1] : "<null>"
	);
	return 1;
}
