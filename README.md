cmt-region
==========

xyzzy用lispです。  
リージョンをコメントアウト／アンコメントします。  
MITライセンスです。  

##目次  
1. 概要  
2. インストール／アンインストール  
3. 使用方法  
4. 設定  
5. 対応言語モード  
6. 改版履歴

* * *

###1.概要  
基本的にはEmacsのcomment-regionのようなものです。  
一応各言語のモードを自動判定して、それにあわせたスタイルでコメント／アンコメントします。  
登録が無いモードは対話的にコメント文字を入力できます。  

xyzzyの設定ファイル（.xyzzy もしくは siteinit.l）に設定を書くことで言語毎の設定の追加や挙動の制御を行えます。  

* * *

###2.インストール／アンインストール  
Netinstallerとか、そげんハイカラなものオラ知らね。...( ´ﾟдﾟ｀)  
ということで、cmt-region.lを、xyzzy/site-lisp/下、もしくはロードパス下に置いてください。  
そして設定ファイル（.xyzzy もしくは siteinit.l）に、以下を追記してください。  

`(load-library "cmt-region.l")`

いうまでもありませんが追記したら再ダンプ（siteinit.lの場合はバイトコンパイルも）が必要です。

アンインストールしたい場合は、cmt-region.lを削除し、設定ファイルからもこれ関係の記述を削除すればおｋです。

* * *

###3.使用方法  
* リージョンをコメントアウトする： `commentout-region`
* リージョンをアンコメントする： `uncomment-region`

リージョンを設定したら、これらをミニバッファに入力すれば普通にコメントアウト／アンコメントが実行されると思います。  
もしバッファの言語モードが、cmt-region.lに登録されてないものだった場合は、コメントの文字を聞いてきますので、入力してください。

蛇足かもしれませんが、こんな感じ↓で  
    (global-set-key '(#\C-c #\c) 'commentout-region)
    (global-set-key '(#\C-c #\u) 'uncomment-region)  
適当なキーバインドを割り当てた方が実用的かと思います（デフォルトでは割り当てられません）。  

できるだけ、先頭行のコメント開始位置のインデントの深さを維持するようにがんばりますが、コメント開始位置よりもインデントが浅い行はコメント位置も浅くなります。また、インデントにタブ文字が使用されている場合は上手くきません。

コメント文字の間に複数行入れられる言語（C言語の`/*`と`*/`とか）もありますが、cmt-regionは律儀に一行ずつコメントを閉じていきます。

* * *

###4.設定
xyzzyの設定ファイル（.xyzzy もしくは siteinit.l)に追記してください。  

・デフォルトにない言語モードを追加する  
例えば、c-modeとlisp-modeの設定はこんな感じです（デフォルトで入ってます）。  
    (setf (gethash 'c-mode *-commentize-mode-table-*) '("/*" "*/"))
    (setf (gethash 'lisp-mode *-commentize-mode-table-*) '(";" nil))  
コメント文字はハッシュテーブル "*-commentize-mode-table-*" にハッシュで格納されます。
モード名はクオートして記入し、同じくクオートしたコメント文字のペアをsetfでがっちゃんこします。
行末や、（聞いたこと無いけど）行頭に入れるコメント文字が必要無い場合はnilとしてください。  

・コメント文字とコメントする文字列の間にスペースを入れるか否か（デフォルト: t）  
`(setq *-let-inside-space-* t)`  
・コメント文字とコメント外文字列の間にスペースを入れるか否か（デフォルト: t）  
`(setq *-let-outside-space-* t)`  

`t`（スペースを入れる）か`nil`（入れない）を選択してください。

・コメント文字とコメントする文字列の間に入れるスペースの数（デフォルト: 1）  
`(setq *-inside-space-width-* 1)`  
・コメント文字とコメント外文字列の間に入れるスペースの数（デフォルト: 2）  
`(setq *-outside-space-width-* 2)`  

スペース数を数値で指定してください。  

asterisk-inside-space-width-asteriskとasterisk-outside-sapce-width-asteriskを0にした場合、asterisk-let-inside-space-asteriskとasterisk-let-inside-space-asteriskをそれぞれnilにしたのと（結果的に）同じ挙動となります。

* * *

###5.対応言語モード
* lisp-mode, lisp-interaction-mode  
行頭に`;`  
* c-mode, css-mode  
行頭に`/*`、行末に`*/`  

* python-mode, py-mode, bash-mode  
行頭に`#`  

* c++-mode, java-mode, javascript-mode  
行頭に`//`  

* basic-mode  
行頭に`'`  

* sql-mode  
行頭に`--`  

* html-mode  
行頭に`<!--`、行末に`-->`  

* pascal-mode  
行頭に`{`、行末に`}`  

コメント方法が複数種類存在する場合（C言語なら`/*`と`*/`、`//`、`#if 0`と`#endif`みたいな）がありますが、今のところ切り替えできるようにはなってません。 (ﾉ∀`)ｱﾁｬｰ  
これから改良したいと思ってます。

* * *

###6.改版履歴
* ドラフト版
