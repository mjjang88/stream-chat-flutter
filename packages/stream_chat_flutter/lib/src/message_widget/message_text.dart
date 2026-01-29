import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// {@template streamMessageText}
/// The text content of a message.
/// {@endtemplate}
class StreamMessageText extends StatelessWidget {
  /// {@macro streamMessageText}
  const StreamMessageText({
    super.key,
    required this.message,
    required this.messageTheme,
    this.onMentionTap,
    this.onLinkTap,
  });

  /// Message whose text is to be displayed
  final Message message;

  /// The action to perform when a mention is tapped
  final void Function(User)? onMentionTap;

  /// The action to perform when a link is tapped
  final void Function(String)? onLinkTap;

  /// [StreamMessageThemeData] whose text theme is to be applied
  final StreamMessageThemeData messageTheme;

  @override
  Widget build(BuildContext context) {
    final streamChat = StreamChat.of(context);
    assert(streamChat.currentUser != null, '');
    return BetterStreamBuilder<String>(
      stream: streamChat.currentUserStream.map((it) => it!.language ?? 'en'),
      initialData: streamChat.currentUser!.language ?? 'en',
      builder: (context, language) {
        var messageText = message
            .translate(language)
            .replaceMentions()
            .text
            ?.replaceAll('\n', '\n\n')
            .trim() ?? '';

        // Convert plain URLs to markdown links so they become clickable
        // This regex matches URLs that are NOT already in markdown link format
        final urlRegex = RegExp(
          r'(?<!\]\()https?://(www\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)',
          caseSensitive: false,
        );
        
        // Find all URL matches and convert them to markdown links
        // Process in reverse order to maintain correct indices
        final matches = urlRegex.allMatches(messageText).toList();
        for (var i = matches.length - 1; i >= 0; i--) {
          final match = matches[i];
          final url = match.group(0)!;
          final start = match.start;
          final end = match.end;
          
          // Convert plain URL to markdown link format: [url](url)
          messageText = messageText.substring(0, start) + 
                       '[$url]($url)' + 
                       messageText.substring(end);
        }

        return StreamMarkdownMessage(
          data: messageText,
          messageTheme: messageTheme,
          selectable: isDesktopDeviceOrWeb,
          onTapLink: (
            String link,
            String? href,
            String title,
          ) {
            if (link.startsWith('@')) {
              final mentionedUser = message.mentionedUsers.firstWhereOrNull(
                (u) => '@${u.name}' == link,
              );

              if (mentionedUser == null) return;

              onMentionTap?.call(mentionedUser);
            } else {
              // Use href if available (from markdown link), otherwise use link
              final urlToOpen = href ?? link;
              if (onLinkTap != null) {
                onLinkTap!(urlToOpen);
              } else {
                launchURL(context, urlToOpen);
              }
            }
          },
        );
      },
    );
  }
}
