local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt

return {
	ls.snippet(
		"doc",
		fmt(
			[[
\documentclass[11pt]{{article}}
\usepackage{{amsmath,amssymb}}
\begin{{document}}
{}
\end{{document}}
]],
			{ ls.insert_node(0) }
		)
	),
}
