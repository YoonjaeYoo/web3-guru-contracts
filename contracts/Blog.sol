pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;


import "./CMSs.sol";
import "./Articles.sol";

contract Blog {
    using CMSs for CMSs.CMS;
    using Articles for Articles.Article;

    CMSs.CMS private cms;

    function getArticle(string memory slug) public view returns (Articles.Article memory) {
        return cms.articleOfSlug[slug];
    }

    function getArticles(uint256 fromIndex, uint256 count) public view returns (Articles.Article[] memory) {
        return cms.getArticles(fromIndex, count);
    }

    function getArticlesOfAuthor(
        address author,
        uint256 fromIndex,
        uint256 count
    ) public view returns (Articles.Article[] memory) {
        return cms.getArticlesOfAuthor(author, fromIndex, count);
    }

    function getArticlesOfTag(
        string memory tag,
        uint256 fromIndex,
        uint256 count
    ) public view returns (Articles.Article[] memory) {
        return cms.getArticlesOfTag(tag, fromIndex, count);
    }

    function getSlugs() public view returns (string[] memory) {
        return cms.allSlugs;
    }

    function getSlugsOfAuthor(address author) public view returns (string[] memory) {
        return cms.slugsOfAuthor[author];
    }

    function getTags() public view returns (string[] memory) {
        return cms.allTags;
    }

    function getSlugsOfTag(string memory tag) public view returns (string[] memory) {
        return cms.slugsOfTag[tag];
    }

    function getLikes(string memory slug) public view returns (Articles.Like[] memory) {
        Articles.Article storage article = cms.articleOfSlug[slug];
        require(article.author != address(0), "article doesn't exist");
        return article.likes;
    }

    function getLikeCount(string memory slug) public view returns (uint256) {
        Articles.Article storage article = cms.articleOfSlug[slug];
        require(article.author != address(0), "article doesn't exist");
        return article.likes.length;
    }

    function getComments(string memory slug) public view returns (Articles.Comment[] memory) {
        Articles.Article storage article = cms.articleOfSlug[slug];
        require(article.author != address(0), "article doesn't exist");
        return article.comments;
    }

    function getCommentCount(string memory slug) public view returns (uint256) {
        Articles.Article storage article = cms.articleOfSlug[slug];
        require(article.author != address(0), "article doesn't exist");
        return article.comments.length;
    }

    function createDraft(
        string memory slug,
        string memory coverImageUrl,
        string memory title,
        string memory excerpt,
        string memory content,
        bytes memory dummy,
        string[] memory tags
    ) public {
        cms.createDraft(slug, coverImageUrl, title, excerpt, content, dummy, tags);
    }

    function update(
        string memory slug,
        string memory coverImageUrl,
        string memory title,
        string memory excerpt,
        string memory content,
        bytes memory dummy,
        string[] memory tags
    ) public {
        cms.update(slug, coverImageUrl, title, excerpt, content, dummy, tags);
    }

    function publish(string memory slug) public {
        Articles.Article storage article = cms.articleOfSlug[slug];
        article.publish();
    }

    function like(string memory slug) public {
        Articles.Article storage article = cms.articleOfSlug[slug];
        article.like();
    }

    function writeComment(string memory slug, string memory content) public {
        Articles.Article storage article = cms.articleOfSlug[slug];
        article.writeComment(content);
    }
}
