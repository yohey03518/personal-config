:mapclear
nmap zso :source ~/erwin.vimrc<CR>
"toggle relative line number
"絕對行號
nmap zrl :set relativenumber!<CR>

"nmap <C-T> :action SearchEverywhere<CR>
nmap <C-S-T> :action GotoAction<CR>
"nmap <C-Tab> :action RecentFiles<CR>
nmap <C-Tab> :action RecentFiles<CR>

nmap zset :action ShowSettings<CR>
nmap <SPACE> :action AceAction<CR>

"Version Control
"nmap zgc :action BuildSolutionAction<CR>:action ActivateCommitToolWindow<CR>
nmap zgc :action ActivateCommitToolWindow<CR>
nmap zgp :action Git.Pull<CR>
nmap zvh :action Vcs.ShowTabbedFileHistory<CR>
"nmap zvH :action Vcs.ShowTabbedFileHistory<CR>

"[Unit Test]"
nmap zrt :action RiderUnitTestRunContextAction<CR>
"無法跑完測試後回去!
nmap zrT ?[TestFixture<CR>k:action RiderUnitTestRunContextAction<CR>
"nmap zrT ?class<CR>w:action RiderUnitTestRunContextAction<CR>:action Back<CR>
"imap <F1> <Esc>jy?[T<CR>P/public<CR>f(b:action ReformatCode<CR>
imap <F1> <Esc>?[Te<CR>Vjj%yjj%p<Esc>:action ReformatCode<CR>
nmap <F1> ?[Te<CR>Vjj%yjj%p<Esc>:action ReformatCode<CR>
nmap zrs dd?class<CR>jo[SetUp]<CR>public<Space>void<Space>SetUp(){<CR>}<Esc>P:action SilentCodeCleanup<CR>
nmap zrx dd?public void Set<CR>j%Pzkzkzz
"無法複合指令!
"nmap zra :action ReformatCode<CR>:action RiderUnitTestRunSolutionAction<CR>
nmap zrA :action SilentCodeCleanup<CR>zra
imap zra <Esc>zra
nmap zra :action RiderUnitTestRunCurrentSessionAction<CR>
nmap ,m :action FileStructurePopup<CR>
nmap zn :action GotoPreviousError<CR>
imap zn <Esc>:action GotoPreviousError<CR>
"zN 找不到 ReSharper_GotoPrevHighlight
"如何關閉選單 類似alt alt
nmap qq ZQ
nmap QW :action CloseAllUnpinnedEditors<CR>
imap QW <Esc>:action CloseAllUnpinnedEditors<CR>
nmap QQ :action CloseAllEditorsButActive<CR>
imap QQ <Esc>:action CloseAllEditorsButActive<CR>
nmap <A-P> :action PinActiveEditorTab<CR>
imap <A-P> <Esc>:action PinActiveEditorTab<CR>
vmap <A-P> :action PinActiveEditorTab<CR>

"alt+J 

nmap <A-u> :redo<CR>
vmap S :action SurroundWith<CR>
"缺少template!
nmap ,c :action Rider.NewFileFromTemplate<CR>
nmap ,g :action Generate<CR>
nmap zk :action Back<CR>
imap zk <Esc>:action Back<CR>
nmap zj :action Forward<CR>
imap zj <Esc>:action Forward<CR>
nmap zf :action GotoDeclaration<CR>
nmap zss :action SelectInProjectView<CR>
imap zss <Esc>:action SelectInProjectView<CR>

imap zsa <Esc>ggvG$
nmap zsa ggvG$
vmap zsa ggvG$

imap zse string.Empty

imap zae Assert.AreEqual(expected,actual);<Esc>T(
nmap zae aAssert.AreEqual(expected,actual);<Esc>T(

""""Refactor
nmap zrr :action RenameElement<CR>
nmap zrm :action Move<CR>
vmap zrm :action Move<CR>
vmap M :action ExtractMethod<CR>
nmap zri :action Inline<CR>
nmap zrp :action IntroduceParameter<CR>
vmap zrp :action IntroduceParameter<CR>
nmap zrf :action IntroduceField<CR>
vmap zrf :action IntroduceField<CR>
nmap zrv :action IntroduceVariable<CR>
vmap zrv :action IntroduceVariable<CR>
nmap zcs :action ChangeSignature<CR>

nmap zmn :action RiderNuGetManagePackagesForCurrentProjectAction<CR>
nmap zxxx :action RiderNuGetShowPackagesAction<CR>
"ReSharperGotoNextErrorInSolution
nmap zaw ^cwreturn<Esc>?async Task<CR>cf <Esc>
nmap z, vi)
nmap z. vi}
nmap z> vit
nmap c> cit
nmap z" vi"
nmap zcc ^ci"
nmap zCC ^ci"
imap jj <Esc>
nmap <BS> a<BS>
nmap hh ^
imap hh <Esc>^i
nmap zl $a
imap zl <Esc>$a
nmap ll $
nmap zt zt2k2j
nmap hc ^C
nmap zb ciw
vmap zb <Esc>ciw
nmap z; $a;<Esc>
imap z; <Esc>$a;

nmap <Tab> :action EditorIndentLineOrSelection<CR>
nmap <S-Tab> :action EditorUnindentSelection<CR>
vmap <Tab> :action EditorIndentLineOrSelection<CR>
vmap <S-Tab> :action EditorUnindentSelection<CR>