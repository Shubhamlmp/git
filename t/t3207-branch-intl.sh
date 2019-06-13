#!/bin/sh

test_description='git branch internationalization tests'

. ./lib-gettext.sh

test_expect_success 'init repo' '
	git init r1 &&
	test_commit -C r1 first
'

test_expect_success GETTEXT_ZH_LOCALE 'detached head sorts before branches' '
	# Ref sorting logic should put detached heads before the other
	# branches, but this is not automatic when a branch name sorts
	# lexically before "(" or the full-width "(" (Unicode codepoint FF08).
	# The latter case is nearly guaranteed for the Chinese locale.

	test_when_finished "git -C r1 checkout master" &&

	git -C r1 checkout HEAD^{} -- &&
	LC_ALL=$zh_CN_locale LC_MESSAGES=$zh_CN_locale \
		git -C r1 branch >actual &&

	head -n 1 actual >first &&
	# The first line should be enclosed by full-width parenthesis.
	grep "（.*）" first &&
	grep master actual
'

test_expect_success 'detached head honors reverse sorting' '
	test_when_finished "git -C r1 checkout master" &&

	git -C r1 checkout HEAD^{} -- &&
	git -C r1 branch --sort=-refname >actual &&

	head -n 1 actual >first &&
	grep master first &&
	test_i18ngrep "HEAD detached" actual
'

test_done
