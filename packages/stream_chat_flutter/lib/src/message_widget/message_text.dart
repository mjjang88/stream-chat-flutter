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
        // This regex matches URLs including those with hyphens in domain, path, and anchor
        // Pattern explicitly allows hyphens in all URL parts (e.g., usa-canada, #_enliple)
        // Simplified pattern to better handle hyphens in path segments
        final urlRegex = RegExp(
          r'(?<!\]\()https?://(?:www\.)?[-\w.]+(?:[:\d]+)?(?:[/?#][-\w/_.~!*'"();:@&=+$,%#\[\]]*)?',
          caseSensitive: false,
        );
        
        // Find all URL matches and convert them to markdown links
        // Process in reverse order to maintain correct indices
        final matches = urlRegex.allMatches(messageText).toList();
        for (var i = matches.length - 1; i >= 0; i--) {
          final match = matches[i];
          var url = match.group(0)!;
          final start = match.start;
          var end = match.end;
          
          // Trim trailing punctuation that's likely not part of the URL
          // But keep punctuation that's valid in URLs (like /, ?, &, =, #, -, etc.)
          while (end > start) {
            final char = messageText[end - 1];
            // Keep URL-valid characters
            if (RegExp(r'[a-zA-Z0-9\-@:%_+.~#?&//=]').hasMatch(char)) {
              break;
            }
            // Stop if we hit whitespace or common sentence-ending punctuation
            if (char == ' ' || char == '\n' || char == '\t' || 
                char == '.' || char == ',' || char == '!' || char == '?' ||
                char == ')' || char == ']' || char == '}' || char == '>') {
              end--;
              url = url.substring(0, url.length - 1);
              break;
            }
            end--;
            url = url.substring(0, url.length - 1);
          }
          
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
