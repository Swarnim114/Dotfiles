/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x0f0f23ff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc3c3c8ff, 0x0f0f23ff, 0x5e5e74ff },
	[SchemeSel]  = { 0xc3c3c8ff, 0x6F758Aff, 0x62677Bff },
	[SchemeUrg]  = { 0xc3c3c8ff, 0x62677Bff, 0x6F758Aff },
};
