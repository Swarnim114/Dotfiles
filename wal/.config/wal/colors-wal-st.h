const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0f0f23", /* black   */
  [1] = "#62677B", /* red     */
  [2] = "#6F758A", /* green   */
  [3] = "#857C90", /* yellow  */
  [4] = "#7C849D", /* blue    */
  [5] = "#8993AF", /* magenta */
  [6] = "#9FAFD8", /* cyan    */
  [7] = "#c3c3c8", /* white   */

  /* 8 bright colors */
  [8]  = "#5e5e74",  /* black   */
  [9]  = "#62677B",  /* red     */
  [10] = "#6F758A", /* green   */
  [11] = "#857C90", /* yellow  */
  [12] = "#7C849D", /* blue    */
  [13] = "#8993AF", /* magenta */
  [14] = "#9FAFD8", /* cyan    */
  [15] = "#c3c3c8", /* white   */

  /* special colors */
  [256] = "#0f0f23", /* background */
  [257] = "#c3c3c8", /* foreground */
  [258] = "#c3c3c8",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
