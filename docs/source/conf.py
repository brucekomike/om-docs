# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

## change required >>>
project = 'om-docs'
copyright = '2025, brucekomike'
author = 'brucekomike'
release = 'v0.0.1'
language='zh_CN'
## change required <<<
# 'en' 'jp' 'zh_CN'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ["sphinx_inline_tabs",
"sphinxext.opengraph",
'sphinx_copybutton',
'myst_parser',
'sphinx.ext.githubpages',
'sphinx_design',
'sphinx_substitution_extensions'
## change required >>>
#'sphinx.ext.mathjax',
]
#mathjax_path = 'tex-svg-full.js'
## change required <<<

# uncomment the two lines upon to have latex support
# js file should placed at _static
# download from here: https://www.mathjax.org/#installnow

myst_enable_extensions = [#
    "amsmath",
    "colon_fence",
    "deflist",
    "dollarmath",
    "fieldlist",
    "html_admonition",
    "html_image",
    "linkify",
    "replacements",
    "smartquotes",
    "strikethrough",
    "substitution",
    "tasklist",
]
source_suffix = {
   '.rst': 'restructuredtext',
   '.txt': 'markdown',
   '.md': 'markdown',
   '': 'markdown',
}

templates_path = ['_templates']
exclude_patterns = ['_build', 'build', 'Thumbs.db',  
  '.gitignore', '.gitattributes', '.git', 'Makefile', 
  '*.py', '*.bat', '*.sh', 'LICENSE'
  'requirements.txt', '*venv', 
  '.DS_Store', '._*',
]

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'furo'
html_static_path = ['_static']
html_extra_path = ['../../src']
## change required >>>
html_title = "om-docs"
html_last_updated_fmt = ''
html_css_files = [
        "footer.css",
]
html_theme_options = {
    # github config here,
    "source_repository": "https://github.com/brucekomike/om-docs",
    "source_branch": "main",
    "source_directory": "docs/source/",
    # key navigation
    "navigation_with_keys": True,
    # gitlab config here,
    #"source_view_link": "https://gitlab.change.this/OWNER/REPO/-/blob/main/docs/source/{filename}",
}
highlight_language = 'bash'
#html_logo = '_static/logo.svg'
#html_favicon = '_static/frameworker.svg'
ogp_site_url = 'https://brucekomike.github.io/om-docs/'
#ogp_image = '_static/logo.svg'
#ogp_image_alt = 'site logo'
ogp_site_name = 'om-docs'
ogp_use_first_image = True
## change required <<<

substitutions_default_enabled = True
myst_substitutions = {
    'url': 'https://brucekomike.github.io/om-docs',
    'mdurl': 'https://brucekomike.github.io/om-docs/_sources',
}