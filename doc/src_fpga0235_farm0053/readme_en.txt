Translation types
Text translation
Source text
= = = = = = = = = = = = = = = ========================= PC - 6001 F Ver. 0234 - 0052 Kopīraito ando Designed by e su bi 2013 - febu - 12 = = = = = = = = = = = = = = = ========================= 1. Hajime ni ¯¯¯¯¯¯ PC - 6001 F to wa, ōnen no pasokon PC - 6001 o FPGA de jitsugen shite shimaou to iu monodesu. 2. Chosakken, shiyō-jō no chūi ¯¯¯¯¯¯¯¯¯¯¯¯ hon kairo, sofuto wa, furīueadesu. T 80 no VHDL kijutsu no chosakken wa, sakushadearu danieru Wallner-san ni arimasu. T 80 koa no ichibu o shūsei shite shiyō shimashita. VDG no naibu kyarakutadēta no chosakken wa, sakushadearu bānī-san ni arimasu. Sonohoka no VHDL kijutsu, puroguramu no chosakken wa, sakushadearu e su bini arimasu. Shiyō suru sai wa, shiyōsha kojin sekinin de okonatte kudasai. Jikkō shita kekka ni yotte, ikanaru kekka ni natte mo, sakusha wa issai sekinin o oimasen'node, go ryōshō kudasai. `Bōdo ga kowareta'`SD kādo no naiyō ga kieta' `bōdo o wazawaza katta no ni, kitai shita mono to chigatta' nado ni kanshite, tōzen sekinin wa oimasen'node. 3. Kaitei kasho ¯¯¯¯¯¯ Ver. 0233 - 0051 Kara, ika no kasho o henkō shite imasu. Onsei gōsei (uPD 7752) kaze o jissō (zantei-ban)! ! Chūi! ! Fairu o sēbu suru sai nado, puroguramu no fuguai nado de SD kādo no naiyō ga hakai sa reru kanōsei ga arimasunode, kanarazu bakkuappu o totte oite kudasai. Mata, SD kādo ni akusesu-chū (reddo 0 ga tentō-chū) wa, SD kādo o nuki sashi shinaide kudasai. 4. Shiyō kankyō ¯¯¯¯¯¯ jitsugen no tame ni wa ika no mono ga hitsuyō ni narimasu. FPGA bōdo DE 0 (Terasic-sei http: / / Www. Terasic. Komu. Tw/ en/ ) VGA ga hyōji dekiru monita PS/ 2 kībōdo SD kādo (jōken ari, kōjutsu) PC - 6001 no romu dēta (BASICROM. 60, CGROM 60. 60) PC - 6001 mk 2 no romu dēta (BASICROM. 62, CGROM 60. 62, CGROM 60 M. 62, VOICEROM. 62, KANJIROM. 62) PC - 6601 no romu dēta (BASICROM. 66, CGROM 60. 66, CGROM 66. 66, VOICEROM. 66, KANJIROM. 66) (Romu dēta wa zenbu hitsuyō wa arimasenga, aru mono shika jikkō dekimasen) ika wa aru to ī monodesu. Onsei shutsuryoku kairo joisutikkupōto ekishō kiban RS - 232 C pōto 5. Junbi ¯¯¯¯ SD kādo SD kādo wa, fatto 16 de fōmatto sa reta mono nomi taiō shite imasu. Saikin no 1 GB ~ 2 GB gurai no mononara, tabun daijōbuda to omoimasu. Mata, SDHC wa taiō shite imasen. SD kādo ni, romu to iu direkutori o sakusei shite, sono naka ni romu dēta o kakunō shite kudasai. Sono, SD kādosurotto ni sashimasu. CMT fairu, kakuchō romu fairu, FDD fairu wa, SD kādo ni kakunō sa rete ireba, direkutori-naideatte mo tokuni mondai arimasen. Namae no seiyaku mo arimasen. Onsei shutsuryoku kairo onsei shutsuryoku kairo wa, GPIO 0 _ D 23 (32 pin) to GND ni sashimasu. Dōkon no karozu no LPF no bubun dake demo dōsa shimasu. Shikashi supīkā o chokusetsu kudō wa dekinainode, iyahon de kii te kudasai. Joisutikkupōto dōkon no joisutikku kairo (to iu ka D - SUB no konekuta) o tsunageba, joisutikku ga tsukaemasu. Tadashi, FPGA no nyūshutsuryoku ga 3. 3 Vde shika taiō dekinai tame, 3. 3 V-yōde wa, 5 V dōsa no mono wa tsukaemasen (tatoeba, 74 LS-kei no IC o tsukatte iru nado). Botanwoosu dake no mono wa, 3. 3 V-yō de shiyō dekimasu. 5 V dōsa no mono (ichibu no rensha paddo, mausu nado) o tsukau baai wa, 5 V-yō o tsukatte kudasai. Ekishō kiban dōkon no karozu o sankō ni shite kudasai. RS - 232 C pōto dōkon no karozu o sankō ni shite kudasai. Kiban migiue kara setsuzoku shimasuga, sukurīn insatsu ga ichibu machigaete irunode ki o tsukete kudasai. Sonota PS/ 2 kībōdo, VGA monita wa, sorezore no konekuta ni sashimasu. Saigo ni, PC 6001. Sof matawa, PC 6001. Pof o DE 0 bōdo ni insutōru shite kudasai. PC 6001. Pof o insutōru shita baai wa, dengen o kitte mo kairo jōhō wa kiemasen. 6. Tsukaikata ¯¯¯¯¯ suraidosuitchi (SW 0 ~ SW 9), pusshusuitchi (BUTTON 0 ~ 2), reddo 0 ~ 9 oyobi 7segu reddo ni ika no koto o wariatete imasu. Reddo 0 ~ 9 reddo 9: Kana kī no injikēta reddo 8: CMT no rirē ON-ji ni tentō reddo 7: CMT no dēta o yomikonde iru sai ni tenmetsu reddo 2: SDRAM no memorierā (tsūjō wa tenmetsu shinai hazudesu) reddo 1: SD kādoerā reddo 0: SD kādo shiyō-chū. SD kādo wa, reddo 0 ga tentō shite iru toki wa, nukisashi shinaide kudasai. Shōtō-chū wa, SD kādo ni akusesu shite imasen'node, nukisashi dekimasuga, dekireba dengen o kitte kara, nukisashi shita kata ga anzendesu. Reddo 1 ga tenmetsu suru baai wa, SD kādo ga haitteinai. SD kādo ga taiō shite inai fōmattodearu. Hitsuyōna romu fairu ga haitteinai. Sonota, akusesu-ji ni erā ga kenshutsu sa reta. No izurekadesu. Risetto o suru (BUTTON 2 o osu) ka, dengen o setsu ￫ nyū shite kudasai. Suraidosuitchi (SW 0 ~ 9)-jō ga ON ni narimasu. SW 9 ~ SW 6: Debaggu-yō. OFF ni shite kudasai. SW 5: ON-ji, ekishō ni hyōji. SW 4: ON-ji, CMT rōdo o tōsoku ni suru. SW 3: ON-ji, PC - 6601 mōdo. SW 2: ON-ji, PC - 6001 mk 2 mōdo. SW 1: OFF ni shite kudasai. SW 0: ON-ji, gamen mabiki mōdo. P 6, mk 2, P 66 o kirikaeru ni wa, SW 2, SW 3 o kirikaete kara, BUTTON 2 (risetto) o oshite kudasai. BUTTON 2 o oshita toki ni SW 2, SW 3 no jōtai o yomikonde, dōsa o kirikaemasu. Gamen mabiki mōdode wa, gamen ga chiratsuite miemasuga, sono-bun no jikan o CPU ni wariatemasu. (Kekka to shite, CPU ga hayaku ugoite iru yō ni miemasu) pusshusuitchi (BUTTON 0 ~ 2), 7segu reddo BUTTON 2: Risetto. Kairo subetewo risetto shimasu. BUTTON 1: CPU adoresu no ratchi. BUTTON 0: 7Segu hyōji serekuto. BUTTON 0 o osu to, CMT kaunta ￫ FPGA - Ver, ￫ fāmu - Ver. ￫ CPU adoresu ￫ CMT kaunta no jun de kawarimasu. CPU adoresu wa, risetto tokiniha" CAdd" ni naru yō ni shite imasu. Kībōdo F 8 o osu to, menyū gamen ni hairimasu. F 11 o osu to, PC - 6001 o risetto shimasu (menyū gamen no naiyō wa risetto sa remasen). PC - 6001 dokuji no kī ni kanshite wa, ika no yō ni wariatete imasu. Ka na: Hankaku/ zenkaku, Pause, namurokku (tenkī) gurafu: ALT PAGE: PageUp STOP: End MODE: Pējidaun mata, tenkī demo kī nyūryoku ga kanōdesu. Menyū gamen shiyō suru kī wa, gamen no shita no ichiran o sankō ni shite kudasai. CMT READ FILE: Yomikomu tēpudebaisu o sentaku shimasu. CMT READ FILE REW. : Yomikomu tēpudebaisu o sentō ni modoshimasu. CMT WRITE FILE: Kakikomu tēpudebaisu o sentaku shimasu. Ramu saizu: 16 KB/ 32 KB (mk 2 no baai, 64 KB/ 128 KB) o sentaku shimasu. Sentaku shita sai wa, PC - 6001 ga jidōteki ni risetto sa remasu. EXTEND romu: Kakuchō romu o sentaku shimasu. Sentaku shita sai wa, PC - 6001 ga jidōteki ni risetto sa remasu. Sarani, yomikomu tēpudebaisu ga, mi sentaku jōtai ni narimasu. SCREEN 4 COLOR: OFF ni suru, moshikuwa iro no kumiawase o sentaku shimasu. UART SETTING: OFF ni suru, moshikuwa bōrēto o sentaku shimasu. Hidari ga 1/ 64 bunshū-ji, migi ga 1/ 16 bunshū-jidesu. Ji pēji (supēsukī de susumimasu) into FDD# 0 SETTING: Naizō doraibu# 0 o shiyō suru ka dō ka o sentaku shimasu. Shiyō suru toki wa, 1 D o erabimasu. Into FDD# 0 FILE: Naizō doraibu# 0 no fairu o sentaku shimasu. Doraibu ga shiyō jōtai no toki ni shika erabemasen. Into FDD# 0 SETTING: Naizō doraibu# 1 o shiyō suru ka dō ka o sentaku shimasu. Shiyō suru toki wa, 1 D o erabimasu. Into FDD# 0 FILE: Naizō doraibu# 1 no fairu o sentaku shimasu. Doraibu ga shiyō jōtai no toki ni shika erabemasen. EXT FDD# 0 SETTING: Sototsuke doraibu# 0 o shiyō suru ka dō ka o sentaku shimasu. Shiyō suru toki wa, 1 D o erabimasu. EXT FDD# 0 FILE: Sototsuke doraibu# 0 no fairu o sentaku shimasu. Doraibu ga shiyō jōtai no toki ni shika erabemasen. EXT FDD# 0 SETTING: Sototsuke doraibu# 1 o shiyō suru ka dō ka o sentaku shimasu. Shiyō suru toki wa, 1 D o erabimasu. EXT FDD# 0 FILE: Sototsuke doraibu# 1 no fairu o sentaku shimasu. Doraibu ga shiyō jōtai no toki ni shika erabemasen. Naizō doraibu wa, PC - 6601 no toki nomi yūkōdesu. Sototsuke doraibu wa, subete no mōdo de shiyō dekimasu. Doraibu o henkō shita toki ni, F 11 de risettosuru to, bēshikku - romu ga ninshiki shimasu. Tēpu no sēbu, rōdo-chū, FDD akusesu-chū wa, menyū no kōmoku no henkō nado wa dekimasen. F 8, F 11 nomi shiyō dekimasu. Chūi: BUTTON 2 de risetto shita baai wa, jōki settei-chi wa subete shokichi ni modorimasu. P 6 T fairu no ōtosutātokomando ni tsuite tēpu no rōdofairu no kakuchōshi ga ~. P 6 T de, ōtosutātokomando o yū ni shite iru baai, sore o jikkō shimasu (tadashi, P 6 T no fōmatto wa Ver. 2 Nomidesu). Tēpu o sentaku-go, F 11 o osu to, risetto kaijo-go, mōdo sentaku, pēji sentaku o okonai, kijutsu sa rete iru komando o jikkō shimasu. Komando o jikkō suru ka dō ka wa, F 11 o osu tabi ni kawarimasu. Tēpu sentaku ￬ F 11 o osu ￫ ōtosutātokomando jikkō ￬ F 11 o osu ￫ tsūjō kidō ￬ F 11 o osu ￫ ōtosutātokomando jikkō: Romu no shurui ga PC - 6001 no baai wa, ramu no saizu mo jidōteki ni henkō shimasu. Mōdo shitei ga 1, 3 no baai wa 16 KB, mōdo shitei ga 2, 4 no baai wa 32 KB ni narimasu. Tēpu no sēbu ni tsuite no seigen sēbu suru toki wa, shinki ni fairu o sakusei suru koto ga dekimasen. Kizon no fairu no ushironi
Show more
5,000 / 5,000
Translation results
========================================
PC-6001F Ver.0234-0052
‥
Copyright and Designed by Esubi
‥
2013-Feb-12
========================================

1. 1. Introduction
￣￣￣￣￣￣

PC-6001F is the old PC-6001
Let's realize it with FPGA.


2. 2. Copyright, precautions for use
￣￣￣￣￣￣￣￣￣￣￣￣
This circuit and software are freeware.

The copyright of the VHDL description of T80 belongs to the author, Daniel Wallner.
A part of the T80 core was modified and used.
The copyright of VDG's internal character data belongs to his author, Bernie.

Other VHDL descriptions and program copyrights belong to the author, Esubi.


When using it, please do it at your own risk. Depending on the result of execution
Please note that the author is not responsible for any consequences.


"The board is broken" "The contents of the SD card have disappeared"
"I bought the board, but it wasn't what I expected."

Of course, we are not responsible for such things.


3. 3. Revised part
￣￣￣￣￣￣
The following parts have been changed from Ver.0233-0051.

・ Implemented voice synthesis (uPD7752) style (provisional version)


! !! Note! !!

The contents of the SD card were damaged due to a program malfunction, such as when saving a file.
Be sure to keep a backup as it may be destroyed.

Also, do not insert or remove the SD card while accessing the SD card (LED0 is lit).


4. usage environment
￣￣￣￣￣￣
The following items are required for realization.

・ FPGA board DE0 (made by Terasic http://www.terasic.com.tw/en/)
・ Monitor that can display VGA
・ PS / 2 keyboard
・ SD card (conditions apply, see below)
・ ROM data of PC-6001 (BASICROM.60, CGROM60.60)
・ ROM data of PC-6001mk2 (BASICROM.62, CGROM60.62, CGROM60M.62, VOICEROM.62, KANJIROM.62)
・ ROM data of PC-6601 (BASICROM.66, CGROM60.66, CGROM66.66, VOICEROM.66, KANJIROM.66)

(You don't need all the ROM data, but you can only execute some)

It would be nice to have the following.
・ Audio output circuit
・ Joystick port
・ Liquid crystal substrate
・ RS-232C port


5. Preparation
￣￣￣￣
・ SD card

SD cards are only compatible with FAT16 formatted ones.
If it's about 1GB to 2GB these days, I think it's probably okay.
Also, SDHC is not supported.

Create a directory called ROM on the SD card and put the ROM data in it
Please store it. Insert it into the SD card slot.

If the CMT file, extended ROM file, and FDD file are stored in the SD card,
There is no particular problem even in the directory. There are no name restrictions.


・ Audio output circuit

Insert the audio output circuit into GPIO0_D23 (pin 32) and GND.

It works only with the LPF part of the included circuit diagram. But the speaker
It cannot be driven directly, so please listen with earphones.


・ Joystick port

If you connect the included joystick circuit (or rather the D-SUB connector),
You can use the joystick.

However, since the input and output of FPGA can only be supported by 3.3V, for 3.3V,
5V operation cannot be used (for example, using a 74LS IC).

The one that just pushes the button can be used for 3.3V.

When using a 5V operation (some continuous shooting pads, mouse, etc.), use the 5V version.
 please use it.


・ Liquid crystal substrate

Please refer to the included circuit diagram.


・ RS-232C port

Please refer to the included circuit diagram.

Connect from the upper right of the board, but be careful as some screen printing is incorrect.


·others

Insert the PS / 2 keyboard and VGA monitor into their respective connectors.

Finally, install PC6001.sof or PC6001.pof on the DE0 board.

If PC6001.pof is installed, the circuit information will not disappear even if the power is turned off.


6. How to use
￣￣￣￣￣
Slide switch (SW0 to SW9), push switch (BUTTON0 to 2), LED0 to 9
The following are assigned to the 7-segment LED and.

・ LED0-9

LED9: Kana key indicator
LED8: Lights when the CMT relay is ON
LED7: Blinks when reading CMT data
LED2: SDRAM memory error (normally should not blink)
LED1: SD card error
LED0: SD card is in use.

Do not insert or remove the SD card when LED0 is lit.
While the light is off, the SD card is not being accessed, so it can be inserted and removed,
If possible, it is safer to turn off the power before inserting or removing it.

If LED1 blinks,
・ SD card is not inserted.
・ It is a format that SD cards do not support.
・ The required ROM file is not included.
・ In addition, an error was detected during access.

It is one of them. Reset (press BUTTON2) or turn off the power → turn on.

・ Slide switch (SW0-9)
The top will be ON.

SW9 to SW6: For debugging. Please turn it off.

SW5: Displayed on the LCD when ON.
SW4: When ON, set the CMT load to a constant speed.
SW3: When ON, PC-6601 mode.
SW2: When ON, PC-6001mk2 mode.
SW1: Please turn it off.
SW0: When ON, screen thinning mode.


To switch between P6, mk2 and P66, switch SW2 and SW3 and then press BUTTON2 (reset).
When BUTTON2 is pressed, the status of SW2 and SW3 is read and the operation is switched.

In the screen thinning mode, the screen looks flickering, but that much time is allocated to the CPU.
(As a result, the CPU seems to be running fast)


・ Push switch (BUTTON0 ～ 2), 7-segment LED

BUTTON2: Reset. Resets the entire circuit.
BUTTON1: CPU address latch.
BUTTON0: 7-segment display select.


When you press BUTTON0,

CMT counter → FPGA-Ver, → FARM-Ver. → CPU address → CMT counter ...
It changes in the order.


The CPU address is set to "CAdd" at the time of reset.


·keyboard

Press F8 to enter the menu screen.
Press F11 to reset PC-6001 (the contents of the menu screen will not be reset).


The keys unique to PC-6001 are assigned as follows.

Kana: Half-width / full-width, Pause, NumLock (tenkey)
GRAPH: ALT
PAGE: PageUp
STOP: End
MODE: PageDown

You can also enter keys with the ten keys.


・ Menu screen

Please refer to the list at the bottom of the screen for the keys to use.

CMT READ FILE: Select the tape device to read.
CMT READ FILE REW .: Returns the tape device to be read to the beginning.
CMT WRITE FILE: Select the tape device to write to.
RAM SIZE: Select 16KB / 32KB (64KB / 128KB for mk2). When selected, PC-6001
It will be automatically reset.
EXTEND ROM: Select the expansion ROM. When selected, PC-6001 will be reset automatically.
Furthermore, the tape device to be read will be in the unselected state.
SCREEN4 COLOR: Turn off or select a color combination.
UART SETTING: Turn off or select the baud rate. The left is 1/64 division time and the right is 1/16 division time.


Next page (press the space key to proceed)

INT FDD # 0 SETTING: Select whether to use the internal drive # 0. When using it, choose 1D.
INT FDD # 0 FILE: Select the file on the internal drive # 0. It can only be selected when the drive is in use.
INT FDD # 0 SETTING: Select whether to use the internal drive # 1. When using it, choose 1D.
INT FDD # 0 FILE: Select the file on the internal drive # 1. It can only be selected when the drive is in use.

EXT FDD # 0 SETTING: Select whether to use the external drive # 0. When using it, choose 1D.
EXT FDD # 0 FILE: Select the file on the external drive # 0. It can only be selected when the drive is in use.
EXT FDD # 0 SETTING: Select whether to use the external drive # 1. When using it, choose 1D.
EXT FDD # 0 FILE: Select the file on the external drive # 1. It can only be selected when the drive is in use.


The internal drive is valid only for PC-6601. The external drive can be used in all modes.
If you change the drive and reset it with F11, BASIC-ROM will recognize it.

Menu items cannot be changed while saving, loading, or accessing FDD of the tape. Only F8 and F11 can be used.


Note: When resetting with BUTTON2, all the above setting values ​​will return to the initial values.



-About the auto start command for P6T files

If the tape load file has an extension of ~ .P6T and has an auto start command,
Execute it (however, the P6T format is Ver.2 only).

After selecting the tape, press F11 to release the reset, select the mode and select the page, and then select the page.
Execute the described command.

Whether to execute the command changes each time you press F11.

Tape selection
↓
Press F11 → Execute auto start command
↓
Press F11 → Normal startup
↓
Press F11 → Execute auto start command
:

If the ROM type is PC-6001, the RAM size will be changed automatically.
If the mode specification is 1 or 3, it will be 16KB, and if the mode specification is 2 or 4, it will be 32KB.


・ Restrictions on saving tapes

When saving, it is not possible to create a new file.
Behind an existing file
More about this source text
Source text required for additional translation information
Send feedback
Side panels
5,000 character limit. Use the arrows to translate more.
