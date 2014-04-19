cmt-region
==========

xyzzy用lispです。  
リージョンをコメントアウト／アンコメントします。  
MITライセンスです。  

###目次
1. 概要
2. インストール／アンインストール
3. 使用方法
4. 設定
5. デフォルト対応言語モード

* * *

###1. 概要
基本的にはEmacsのcomment-regionのようなものです。  
ネットを漁ってみましたがxyzzy版は見かけなかったので自分で作ってみました。  
一応各言語のモードを自動判定して、それにあわせたスタイルでコメント／アンコメントします。  
登録が無いモードは対話的にコメント文字を入力できます。  

xyzzyの設定ファイル（.xyzzy もしくは siteinit.l）に設定を書くことで言語毎の設定の追加や挙動の制御を行えます。  

* * *

###2. インストール／アンインストール
* インストール  
    Netinstallerとか、そげんハイカラなものオラ知らね。...( ´ﾟдﾟ｀)  
    ということで、cmt-region.lを、xyzzy/site-lisp/下、もしくはロードパス下に置き、設定ファイル（.xyzzy もしくは siteinit.l）に、以下を追記してください。
    ```lisp
    (load-library "cmt-region.l")
    ```
    いうまでもありませんが追記したら再ダンプ（siteinit.lの場合はバイトコンパイルも）が必要です。

* アンインストール  
    アンインストールしたい場合は、cmt-region.lを削除し、設定ファイルからもこれ関係の記述を削除すればおｋです。

* * *

###3. 使用方法
* リージョンをコメントアウトする： `commentout-region`
* リージョンをアンコメントする： `uncomment-region`

リージョンを設定したら、これらをミニバッファに入力すれば普通にコメントアウト／アンコメントが実行されると思います。  
もしバッファの言語モードが、設定されてないものだった場合は、コメントの文字を聞いてきますので、入力してください。

蛇足かもしれませんが、こんな感じ↓で適当なキーバインドを割り当てた方が実用的かと思います（デフォルトでは割り当てられません）。
```lisp
(global-set-key '(#\C-c #\c) 'commentout-region)
(global-set-key '(#\C-c #\u) 'uncomment-region)
```
できるだけ先頭行のコメント開始位置のインデントの深さを維持するよう頑張ってくれますが、開始位置よりもインデントが浅い行はコメント位置も浅くなります。  
また、インデントにタブ文字が使用されている場合は上手くきません。

コメント文字の間に複数行入れられる言語（C言語の`/*`と`*/`など）もありますが、cmt-regionは律儀に一行ずつコメントを閉じていきます。

* * *

###4. 設定
お好みでxyzzyの設定ファイル（.xyzzy もしくは siteinit.l)に追記してください。

* デフォルトにない言語モードを追加する  
    例えば、c-modeとlisp-modeの設定はこんな感じです（これらはデフォルトで入ってます）。
    ```lisp
    (setf (gethash 'c-mode *-commentize-mode-table-*) '("/*" "*/"))
    (setf (gethash 'lisp-mode *-commentize-mode-table-*) '(";" nil))
    ```
    コメント文字はハッシュテーブル \*-commentize-mode-table-\* にハッシュで格納されます。  
    モード名はクオートして記入し、同じくクオートしたコメント文字のペアを`setf`でがっちゃんこします。  
    行末や、（聞いたこと無いけど）行頭に入れるコメント文字が必要無い場合はnilとしてください。  

* コメント文字とコメントする文字列の間に空白文字を入れるか否か  
    `t`（空白文字を入れる）か`nil`（入れない）を選択してください。（デフォルト: t）
    ```lisp
    (setq *-let-inside-space-* t)
    ```

* コメント文字とコメント外文字列の間に空白文字を入れるか否か  
    `t`（空白文字を入れる）か`nil`（入れない）を選択してください。（デフォルト: t）
    ```lisp
    (setq *-let-outside-space-* t)
    ```

* コメント文字とコメントする文字列の間に入れる空白文字の数  
    空白文字数を数値で指定してください。（デフォルト: 1）
    ```lisp
    (setq *-inside-space-width-* 1)
    ```

* コメント文字とコメント外文字列の間に入れる空白文字の数  
    空白文字数を数値で指定してください。（デフォルト: 2）
    ```lisp
    (setq *-outside-space-width-* 2)
    ```

\*-inside-space-width-\*と\*-outside-space-width-\*を0にした場合、\*-let-inside-space-\*と\*-let-inside-space-\*をそれぞれnilにしたのと（結果的に）同じ挙動となります。

* * *

###5. デフォルト対応言語モード
* lisp-mode, lisp-interaction-mode  
先頭に`;`が付きます。

* c-mode, css-mode  
先頭に`/*`、末尾に`*/`が付きます。

* python-mode, py-mode, bash-mode  
先頭に`#`が付きます。

* c++-mode, java-mode, javascript-mode  
先頭に`//`が付きます。

* basic-mode  
先頭に`'`が付きます。

* sql-mode  
先頭に`--`が付きます。

* html-mode  
先頭に`<!--`、末尾に`-->`が付きます。

* pascal-mode  
先頭に`{`、末尾に`}`が付きます。

ここに書かれていない言語に関しては前述の通り、\*-commentize-mode-table-\*に追加する事で設定できます。
コメント方法が複数種類存在する言語（Cで言えば`/*`と`*/`、`//`、`#if 0`と`#endif`みたいなん）がありますが、今のところ切り替えできるようにはなってません。
