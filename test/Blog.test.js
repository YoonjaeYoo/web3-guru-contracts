const {ethers} = require("@nomiclabs/buidler");
const {use, expect} = require("chai");
const {solidity, getWallets, deployContract, link} = require("ethereum-waffle");
const StringArrays = require("../build/StringArrays");
const CMSs = require("../build/CMSs");
const Articles = require("../build/Articles");
const Blog = require("../build/Blog");

use(solidity);
use(require("chai-bignumber")());

const expectTestArticle = (article) => {
    expect(article.slug).to.equal("test-slug");
    expect(article.revisions[0].coverImageUrl).to.equal("https://upload.wikimedia.org/wikipedia/commons/c/c4/PM5544_with_non-PAL_signals.png");
    expect(article.revisions[0].title).to.equal("Article1");
    expect(article.revisions[0].excerpt).to.equal("Excerpt1");
    expect(article.revisions[0].content).to.equal("Content1");
    expect(article.tags).to.deep.equal(["test-tag"]);
};

const expectTestArticleUpdated = (article) => {
    expect(article.slug).to.equal("test-slug");
    expect(article.revisions[0].coverImageUrl).to.equal("https://");
    expect(article.revisions[0].title).to.equal("Article1-1");
    expect(article.revisions[0].excerpt).to.equal("Excerpt1-1");
    expect(article.revisions[0].content).to.equal("Content1-1");
    expect(article.tags).to.deep.equal(["test-tag-1"]);
};

describe('Blog smart contract', () => {
    const [wallet] = getWallets(ethers.provider);
    let blog;

    before(async () => {
        const stringArrays = await deployContract(wallet, StringArrays, []);
        link(CMSs, "contracts/StringArrays.sol:StringArrays", stringArrays.address);
        const cmss = await deployContract(wallet, CMSs, []);
        const articles = await deployContract(wallet, Articles, []);
        link(Blog, "contracts/CMSs.sol:CMSs", cmss.address);
        link(Blog, "contracts/Articles.sol:Articles", articles.address);
    });

    beforeEach(async () => {
        blog = await deployContract(wallet, Blog, []);
    });

    it("creates draft", async () => {
        await blog.functions.createDraft(
            "test-slug",
            "https://upload.wikimedia.org/wikipedia/commons/c/c4/PM5544_with_non-PAL_signals.png",
            "Article1",
            "Excerpt1",
            "Content1",
            "0x",
            ["test-tag"],
        );
        expect(await blog.functions.getSlugs()).to.deep.equal(["test-slug"]);
        expect(await blog.functions.getSlugsOfAuthor(wallet.address)).to.deep.equal(["test-slug"]);
        expect(await blog.functions.getTags()).to.deep.equal(["test-tag"]);
        expect(await blog.functions.getSlugsOfTag("test-tag")).to.deep.equal(["test-slug"]);
        expectTestArticle(await blog.functions.getArticle("test-slug"));
        expectTestArticle((await blog.functions.getArticlesOfAuthor(wallet.address, 0, 1))[0]);
        expectTestArticle((await blog.functions.getArticlesOfTag("test-tag", 0, 1))[0]);
    });

    it("updates article", async () => {
        await blog.functions.createDraft(
            "test-slug",
            "https://upload.wikimedia.org/wikipedia/commons/c/c4/PM5544_with_non-PAL_signals.png",
            "Article1",
            "Excerpt1",
            "Content1",
            "0x",
            ["test-tag"]
        );
        await blog.functions.update(
            "test-slug",
            "https://",
            "Article1-1",
            "Excerpt1-1",
            "Content1-1",
            "0x",
            ["test-tag-1"]
        );
        expect(await blog.functions.getTags()).to.deep.equal(["test-tag-1"]);
        expect(await blog.functions.getSlugsOfTag("test-tag-1")).to.deep.equal(["test-slug"]);
        expectTestArticleUpdated(await blog.functions.getArticle("test-slug"));
        expectTestArticleUpdated((await blog.functions.getArticlesOfAuthor(wallet.address, 0, 1))[0]);
        expectTestArticleUpdated((await blog.functions.getArticlesOfTag("test-tag-1", 0, 1))[0]);
    });

    it("likes article", async () => {
        await blog.functions.createDraft(
            "test-slug",
            "https://upload.wikimedia.org/wikipedia/commons/c/c4/PM5544_with_non-PAL_signals.png",
            "Article1",
            "Excerpt1",
            "Content1",
            "0x",
            ["test-tag"]
        );
        expect(await blog.functions.getLikeCount("test-slug")).to.be.bignumber.equal("0");
        await blog.functions.like("test-slug");
        expect(await blog.functions.getLikeCount("test-slug")).to.be.bignumber.equal("1");
        const likes = await blog.functions.getLikes("test-slug");
        expect(likes[0].liker).to.be.equal(wallet.address);
    });

    it("writes comment on article", async () => {
        await blog.functions.createDraft(
            "test-slug",
            "https://upload.wikimedia.org/wikipedia/commons/c/c4/PM5544_with_non-PAL_signals.png",
            "Article1",
            "Excerpt1",
            "Content1",
            "0x",
            ["test-tag"]
        );
        expect(await blog.functions.getCommentCount("test-slug")).to.be.bignumber.equal("0");
        await blog.functions.writeComment("test-slug", "Comment");
        expect(await blog.functions.getCommentCount("test-slug")).to.be.bignumber.equal("1");
        const comments = await blog.functions.getComments("test-slug");
        expect(comments[0].writer).to.be.equal(wallet.address);
        expect(comments[0].content).to.be.equal("Comment");
    });
});
