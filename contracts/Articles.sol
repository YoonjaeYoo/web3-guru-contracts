pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;


library Articles {
    struct Article {
        string slug;
        address author;
        uint256 publishedAt;
        string[] tags;
        Revision[] revisions;
        Like[] likes;
        Comment[] comments;
    }

    struct Revision {
        string coverImageUrl;
        string title;
        string excerpt;
        string content;
        bytes dummy;
        uint256 createdAt;
    }

    struct Like {
        address liker;
        uint256 createdAt;
    }

    struct Comment {
        address writer;
        string content;
        uint256 createdAt;
    }

    function publish(Article storage article) public {
        require(article.author == msg.sender, "only author can update");
        require(article.publishedAt == 0, "already published");

        article.publishedAt = now;
    }

    function like(Article storage article) public {
        require(article.author != address(0), "article doesn't exist");

        for (uint256 i = 0; i < article.likes.length; i++) {
            if (article.likes[i].liker == msg.sender) {
                require(false, "you already like this article");
            }
        }
        article.likes.push(Articles.Like(msg.sender, now));
    }

    function writeComment(Article storage article, string memory content) public {
        require(article.author != address(0), "article doesn't exist");

        article.comments.push(Comment(msg.sender, content, now));
    }
}
