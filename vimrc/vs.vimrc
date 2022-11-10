"nmap zcc :mapclear!<CR>
"switch absolute line number
"set number! 
nmap zso :source C:\Users\erwin.chang73\_vimrc <CR>
nmap zstest :source D:\_vimrctest <CR>
nmap zsjoey :source C:\Users\erwin.chang73\_vimrc91 <CR>
imap <F4> <Esc>y?[T<CR>p/void<CR>w
nmap <F4> jy?[T<CR>p/void<CR>w
imap <F2> <Esc>y?[Fact<CR>p/void<CR>w
nmap <F2> y?[Fact<CR>p/void<CR>w
nmap zm :make<CR>
nmap gt :vsc TestExplorer.ShowTestExplorer<CR>
"nmap zra zz:vsc ReSharper.ReSharper_ReformatCode<CR>zz:vsc ReSharper.Resharper_UnitTestSessionRepeatPreviousRun<CR>
nmap zra :vsc ReSharper.ReSharper_SilentCleanupCode<CR>zz:vsc ReSharper.ReSharper_UnitTestRunCurrentSession<CR>
imap zra <Esc>zz:vsc ReSharper.ReSharper_ReformatCode<CR>zz:vsc ReSharper.Resharper_UnitTestSessionRepeatPreviousRun<CR>
vmap zra <Esc><Esc>:vsc ReSharper.ReSharper_CompleteStatement<CR>:vsc ReSharper.ReSharper_ReformatCode<CR>:vsc CodeMaid.CleanupActiveDocument<CR>zz:vsc ReSharper.Resharper_UnitTestSessionRepeatPreviousRun<CR>

"nmap zra zz:vsc CodeMaid.CleanupActiveDocument<CR>:vsc TestExplorer.RunAllTests<CR>:vsc TestExplorer.ShowTestExplorer<CR>
"imap zra <Esc>zz:vsc CodeMaid.CleanupActiveDocument<CR>make<CR>:vsc TestExplorer.RunAllTests<CR>:vsc TestExplorer.ShowTestExplorer<CR>
"vmap zra <Esc><Esc>zz:vsc CodeMaid.CleanupActiveDocument<CR>make<CR>:vsc TestExplorer.RunAllTests<CR>:vsc TestExplorer.ShowTestExplorer<CR>

nmap zec :vsc CodeMaid.CleanupActiveDocument<CR>:vsc ReSharper.ReSharper_SilentCleanupCode<CR>zz

"nmap zrl zz:vsc ReSharper.ReSharper_ReformatCode<CR>make<CR>:vsc ReSharper.ReSharper_UnitTestSessionRepeatPreviousRun<CR>
"imap zrl <Esc>zz:vsc ReSharper.ReSharper_ReformatCode<CR>:vsc ReSharper.ReSharper_UnitTestSessionRepeatPreviousRun<CR>
nmap zgc :vsc Build.BuildSolution<CR>:vsc Team.Git.GotoGitChanges<CR>
"nmap zgc zz:vsc ReSharper.ReSharper_ReformatCode<CR>:make<CR>:vsc Team.Git.GotoGitChanges<CR>
nmap zgp :vsc Team.Git.Pull<CR>
nmap zk :vsc View.NavigateBackward<CR>
imap zk <Esc>:vsc View.NavigateBackward<CR>
nmap zj :vsc View.NavigateForward<CR>
imap zj <Esc>:vsc View.NavigateForward<CR>

nmap zss :vsc SolutionExplorer.SyncWithActiveDocument<CR>
imap zss <Esc>:vsc SolutionExplorer.SyncWithActiveDocument<CR>

imap zse string.Empty<Esc>a

nmap gw1 :vsc Window.ApplyWindowLayout1<CR>
nmap gw2 :vsc Window.ApplyWindowLayout2<CR>
nmap gw3 :vsc Window.ApplyWindowLayout3<CR>
nmap gw4 :vsc Window.ApplyWindowLayout4<CR>
nmap gw5 :vsc Window.ApplyWindowLayout5<CR>
nmap gw6 :vsc Window.ApplyWindowLayout6<CR>
nmap gw7 :vsc Window.ApplyWindowLayout7<CR>
nmap gfs :vsc View.FullScreen<CR>

imap zae Assert.AreEqual(expected,actual);<Esc>T(
nmap zae aAssert.AreEqual(expected,actual);<Esc>T(

nmap zrr :vsc ReSharper.ReSharper_Rename<CR><Esc>
nmap zrm :vsc ReSharper.ReSharper_Move<CR>
vmap zrm :vsc ReSharper.ReSharper_Move<CR>
vmap M :vsc ReSharper.ReSharper_ExtractMethod<CR><Esc>

imap zsa <Esc>ggvG$
nmap zsa ggvG$
vmap zsa ggvG$

nmap zrn :vsc ReSharper.ReSharper_MakeNonStatic<CR>
vmap zrn :vsc ReSharper.ReSharper_MakeNonStatic<CR><Esc>

nmap zgf :vsc Edit.GoToReference<CR>

"nmap znuget :vsc Tools.ManageNuGetPackagesforSolution<CR>
"nmap zng :vsc Tools.ManageNuGetPackagesforSolution<CR>
nmap zmn :vsc Tools.ManageNuGetPackagesforSolution<CR>

map zsp vi":vsc ReSharper.ReSharper_IntroduceParameter<CR><Esc>
map zrp v:vsc ReSharper.ReSharper_IntroduceParameter<CR><Esc>
vmap P :vsc ReSharper.ReSharper_IntroduceParameter<CR><Esc>
map zri :vsc ReSharper.ReSharper_InlineVariable<CR><Esc>
map zrv :vsc ReSharper.ReSharper_IntroVariable<CR><Esc>

nmap zrf :vsc ReSharper.ReSharper_IntroduceField<CR><Esc>
vmap zrf :vsc ReSharper.ReSharper_IntroduceField<CR><Esc>
"nmap zrt :vsc ReSharper.ReSharper_GotoType<CR>
nmap zrt :vsc ReSharper.ReSharper_UnitTestRunFromContext<CR>
imap zrt <Esc>:vsc ReSharper.ReSharper_UnitTestRunFromContext<CR>
nmap zrT ?class<CR>w:vsc ReSharper.ReSharper_UnitTestRunFromContext<CR>zk
imap zrT <Esc>?class<CR>:vsc ReSharper.ReSharper_UnitTestRunFromContext<CR>zk
nmap zro :vsc ReSharper.ReSharper_Move<CR>
nmap zsc :vsc ReSharper.ReSharper_ShowCodeStructure<CR> 
nmap zcs :vsc ReSharper.ReSharper_ChangeSignature<CR>

nmap zpm :vsc ReSharper.ReSharper_PasteMultiple<CR>
imap zpm <Esc>:vsc ReSharper.ReSharper_PasteMultiple<CR>
nmap ,m :vsc ReSharper.ReSharper_GotoFileMember<CR>
nmap zf :vsc ReSharper.ReSharper_GoToDeclaration<CR>:vsc EditorContextMenus.CodeWindow.Navigate.ReSharper_NavigateToParameter<CR>
imap zf <Esc>:vsc ReSharper.ReSharper_GoToDeclaration<CR>:vsc EditorContextMenus.CodeWindow.Navigate.ReSharper_NavigateToParameter<CR>

nmap zpf ?new <CR>cf Substitute.For<I<Esc>f(i><Esc>ma?Substitute<CR>vf)
imap zpf <Esc>zpf

"nmap gp :vsc EditorContextMenus.CodeWindow.Navigate.ReSharper_NavigateToParameter<CR>

nmap zn :vsc ReSharper.ReSharper_GotoPrevErrorInSolution<CR>
imap zn <Esc>:vsc ReSharper.ReSharper_GotoPrevErrorInSolution<CR>a
nmap zN :vsc ReSharper.ReSharper_GotoPrevHighlight<CR>
imap zN <ESC>:vsc ReSharper.ReSharper_GotoPrevHighlight<CR>
"imap zN <Esc>:vsc ReSharper.ReSharper_GotoPrevHighlight<CR>

nmap zrc :vsc ReSharper.ReSharper_ReformatCode<CR>
imap zrc <Esc>:vsc ReSharper.ReSharper_ReformatCode<CR>
nmap zrz :vsc CodeMaid.ReorganizeActiveDocument<CR>
imap zrz <Esc>:vsc CodeMaid.ReorganizeActiveDocument<CR>

nmap z; $a;<Esc>
imap z; <Esc>$a;

nmap zvh :vsc Team.Git.ViewHistory<CR>

nmap <C-CR> mza<CR><Esc>`z

nmap z] :vsc ReSharper_HumpNext<CR>
nmap z[ :vsc ReSharper_HumpPrev<CR>

nmap ,t :vsc EditorContextMenus.CodeWindow.CreateUnitTests<CR>
nmap ,c :vsc ReSharper.ReSharper_GenerateFileBesides<CR>
nmap ,g :vsc ReSharper.ReSharper_Generate<CR>
vmap S :vsc ReSharper.ReSharper_SurroundWith<CR>

nmap zrs dd?class<CR>jo[SetUp]<CR>public<Space>void<Space>SetUp(){<CR>}<Esc>P:vsc ReSharper.ReSharper_SilentCleanupCode<CR>
"nmap zrs i//aa<Esc>:vsc ReSharper.ReSharper_SilentCleanupCode<CR>
nmap zpp :vsc Edit.LineCut<CR><CR>
:nmap zrx dd?public void Set<CR>j%Pzkzkzz

nmap <SPACE> :vsc Tools.InvokeAceJumpCommand<CR>

nmap z/ ?><CR>wv/<<CR>bt<
imap z/ <Esc>z/

nmap zjp hhf{bvt y<Esc>O[JsonProperty("<Esc>pT"~
imap <Esc>zjp

nmap z` :vsc View.SolutionExplorer<CR>
vmap z` :vsc View.SolutionExplorer<CR>
imap z` :vsc View.SolutionExplorer<CR>

"toggle relative line number
nmap zrl :set rnu!<CR>

nmap ,p "0p
nmap ,P "0P
imap z,p <Esc>"0pa
imap z,P <Esc>"0Pa
:nmap z, vi)
:nmap z. vi}
:nmap z) vi)
:nmap z} vi}
:nmap z> vit
:nmap c> cit
:nmap z" vi"
:nmap zcc ^ci"
:nmap zvv ^vi'
:vmap zvv <ESC>^vi'
:nmap zaa ca"
:nmap zxx ci]
:vmap <Esc> <Esc><Esc><Esc>
:imap jj <Esc>
:nmap <BS> a<BS>
:nmap zh ^
:nmap hh ^
:imap hh <Esc>^i
:imap zh <Esc>^i
:nmap zl $a
:nmap ll $
:imap zl <End>
:nmap zgt ?void<CR>w
:nmap zt zt2k2j
:nmap hc ^C
:nmap zb ciw
:vmap zb <Esc>ciw
:imap zd <Esc>dd
nmap qq ZQ
nmap QW :vsc Window.CloseAllButPinned<CR>
imap QW <Esc>:vsc Window.CloseAllButPinned<CR>
nmap QQ :vsc File.CloseAllButThis<CR>
imap QQ <Esc>:vsc File.CloseAllButThis<CR>
nmap <A-u> :redo<CR>
:imap <C-x> <Esc>dd
:imap <C-a> <Esc>ma<CR>ggVG
" map C :set rnu!<CR>
" insert single char
:map ,i i?<Esc>r
" append single char
:map ,a a?<Esc>r
nmap zaw ^cwreturn<Esc>?async Task<CR>cf <Esc>