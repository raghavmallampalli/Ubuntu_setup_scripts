# Useful code for making cleaner plots in python
import re
import matplotlib.pyplot as plt
import seaborn as sns

rogov_teal = "#009999"
rogov_green = "#36b45c"
rogov_orange = "#ff6600"
rogov_orangered = "#dd3425"
rogov_darkpurple = "#1c1c29"
rogov_lightblue = "#31bfb9"

# NOTE: NEVER use these custom colors if there are more datasets than number of colors (6). 
plot_color_list = [
    rogov_teal,rogov_orange,rogov_green,
    rogov_lightblue,rogov_orange,rogov_darkpurple,
    rogov_orangered
    ]

# MATPLOTLIB
sns.set(font='Franklin Gothic Book',
        rc={
            'axes.axisbelow': False,
            'axes.edgecolor': 'lightgrey',
            'axes.facecolor': 'None',
            'axes.grid': False,
            'axes.labelcolor': 'dimgrey',
            'axes.spines.right': False,
            'axes.spines.top': False,
            'figure.facecolor': 'white',
            'lines.solid_capstyle': 'round',
            'patch.edgecolor': 'w',
            'patch.force_edgecolor': True,
            'text.color': 'dimgrey',
            'xtick.bottom': False,
            'xtick.color': 'dimgrey',
            'xtick.direction': 'out',
            'xtick.top': False,
            'ytick.color': 'dimgrey',
            'ytick.direction': 'out',
            'ytick.left': False,
            'ytick.right': False,
            }
        )
sns.set_context(
                "notebook",
                rc={
                    "font.size":16,
                    "axes.titlesize":20,
                    "axes.labelsize":18
                    }
                )
def colourGradient(fromRGB, toRGB, steps=50):
    """
    colourGradient(fromRGB, toRGB, steps=50)
    Returns a list of <steps> html-style colour codes forming a 
    gradient between the two supplied colours steps is an optional
    parameter with a default of 50
    If fromRGB or toRGB is not a valid colour code (omitting the initial hash sign is permitted),
    an exception is raised.

    Peter Cahill 2020
    """
    # So we can check format of input html-style colour codes
    hexRgbRe = re.compile(r"#?[0-9a-fA-F]{6}")
    # The code will handle upper and lower case hex characters,
    # with or without a # at the front
    if not hexRgbRe.match(fromRGB) or not hexRgbRe.match(toRGB):
        raise Exception("Invalid parameter format") 
        # One of the inputs isn't a valid rgb hex code

    # Tidy up the parameters
    rgbFrom = fromRGB.split("#")[-1]
    rgbTo = toRGB.split("#")[-1]

    # Extract the three RGB fields as integers
    # from each (from and to) parameter
    rFrom, gFrom, bFrom = [(
        int(rgbFrom[n:n+2], 16
        )) for n in range(0, len(rgbFrom), 2)]
    rTo, gTo, bTo = [(
        int(rgbTo[n:n+2], 16
        )) for n in range(0, len(rgbTo), 2)]

    # For each colour component, generate the intermediate steps
    rSteps = ["#{0:02x}".format(round(
        rFrom + n * (rTo - rFrom) / (steps - 1)
        )) for n in range(steps)]
    gSteps = ["{0:02x}".format(round(
        gFrom + n * (gTo - gFrom) / (steps - 1)
        )) for n in range(steps)]
    bSteps = ["{0:02x}".format(round(
        bFrom + n * (bTo - bFrom) / (steps - 1)
        )) for n in range(steps)]

    # Reassemble the components into a list of html-style #rrggbb codes
    return [r+g+b for r, g, b in zip(rSteps, gSteps, bSteps)]

plt.rcParams['axes.prop_cycle'] = plt.cycler(color=plot_color_list)
# Credits to Callum Ballard and Peter Cahill

# Useful commands and settings
# alpha: transparency
# plt.scatter(..., alpha=0.5)
#
# horizontal and vertical line:
# plt.axhline(Y_POSITION, ...)  #horizontal line
# plt.axvline(X_POSITION, ...)  #vertical line
#
# annotate on graph:
# plt.annotate(TEXT, (X_POSITION, Y_POSITION), ...)
#
# xkcd library:
# https://xkcd.com/color/rgb/
# good ones:-
# seafoam, lightish blue, apple green, red, brick red, coral,
# reddish orange, jungle green, golden yellow
# plot(...,color="xkcd:lightish blue")

# PLOTLY: check ./plotly_testing.ipynb for code reference
import plotly.express as px
import plotly.graph_objects as go
df = px.data.tips()
fig1 = px.scatter(
    df, x="total_bill", y="tip", color="day",
    color_discrete_sequence=plot_color_list,
    title="Custom colors in plotly",
    )