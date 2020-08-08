import argparse


def gaana_song_type(arg_value):
    if 'gaana.com/song/' not in arg_value:
        raise argparse.ArgumentTypeError('Enter valid gaana.com url')
    return arg_value


def parse_song(args):
    parser = argparse.ArgumentParser(
        description="Gaana.com Downloader")
    parser.add_argument(
        dest="song_link",
        help="Gaana.com Song Link",
        type=gaana_song_type,
        metavar="<song_url>")
    # parser.add_argument(
    #     '-o', '--out',
    #     dest='output_path',
    #     help='Output file path',
    #     metavar="output_path")
    args_parsed = parser.parse_args(args)

    return str(args_parsed.song_link)
    # , args_parsed.output_path
